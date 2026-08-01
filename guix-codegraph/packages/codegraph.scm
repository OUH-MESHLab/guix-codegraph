;;; guix-codegraph --- Guix channel for CodeGraph code-intelligence CLI
;;; Copyright © 2026 Rafael Palomar <rafael.palomar@ous-research.no>
;;;
;;; This file is part of guix-codegraph.
;;;
;;; guix-codegraph is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by the Free
;;; Software Foundation; either version 3 of the License, or (at your option)
;;; any later version.
;;;
;;; guix-codegraph is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for more details.
;;;
;;; You should have received a copy of the GNU General Public License along
;;; with guix-codegraph.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;;
;;; Upstream : https://github.com/colbymchenry/codegraph
;;; License  : MIT (Expat)
;;; Build    : node-build-system, compiled from git source with tsc.
;;;
;;; Build notes
;;; -----------
;;; codegraph is a TypeScript project; the npm tarball for the published
;;; @colbymchenry/codegraph package is a download shim, NOT the compiled
;;; application.  We therefore build from the git source tree.
;;;
;;; TypeScript compilation uses `tsc --noCheck` (TypeScript >= 5.5) to skip
;;; type-checking in the build sandbox.  This eliminates the need for
;;; @types/node and other type-only devDependencies in the store without
;;; affecting the correctness of the emitted JavaScript (type-checking is
;;; the upstream CI's responsibility; here we only transpile).
;;;
;;; The installed bin ($out/bin/codegraph) is a shell wrapper that:
;;;   1. Passes --liftoff-only to the Node V8 engine, disabling the
;;;      turboshaft WASM JIT.  This prevents Zone OOM crashes when
;;;      compiling large tree-sitter grammars on Node >= 22 (see
;;;      src/extraction/wasm-runtime-flags.ts).  Because --liftoff-only
;;;      is already in process.execArgv when the script starts,
;;;      processHasWasmRuntimeFlags() returns true and the in-process
;;;      re-exec is skipped entirely.
;;;   2. Defaults CODEGRAPH_TELEMETRY to "0" (anonymous telemetry off),
;;;      while allowing users to override from their shell.
;;;
;;; node-jsonc-parser (3.3.1) is an exact version match in upstream Guix
;;; (gnu packages node-xyz) and is reused directly.
;;; node-typescript (5.8.3) from the same module provides tsc as a
;;; native-input (build-time only; not in the runtime closure).
;;;
;;; Code:

(define-module (guix-codegraph packages codegraph)
  #:use-module (guix-codegraph packages node-codegraph-deps)
  #:use-module (gnu packages node)            ; node-lts (>= 22.16: FTS5 in node:sqlite)
  #:use-module (gnu packages node-xyz)        ; node-jsonc-parser, node-typescript
  #:use-module (guix build-system node)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages))


(define %codegraph-commit
  "4aa2752ef1abdcc436bc6617d6430beea74e16c9")

(define %codegraph-version
  (git-version "1.0.1" "0" %codegraph-commit))


(define-public codegraph
  (package
    (name "codegraph")
    (version %codegraph-version)
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
              (url "https://github.com/colbymchenry/codegraph")
              (commit %codegraph-commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "15gw2r9cqy96wdvamk9p6rck0zkk9r87mj0hsb1y8vk4ycqkr9mb"))))
    (build-system node-build-system)
    (arguments
     (list
      #:node node-lts
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases

          ;; Remove devDependencies that are either unavailable in the store or
          ;; not needed because we compile with --noCheck (the @types/* packages)
          ;; or are replaced by native-inputs (typescript).
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dev-dependencies))))

          ;; Replace the default build phase with explicit steps matching the
          ;; upstream `npm run build` script:
          ;;   tsc && npm run copy-assets && chmod dist/bin/codegraph.js 0755
          ;; We invoke each step directly to avoid relying on npm in the sandbox.
          (replace 'build
            (lambda _
              (use-modules (guix build utils))
              ;; Transpile TypeScript → CommonJS (outDir: ./dist, per tsconfig.json).
              ;; --noCheck: emit without type-checking (TypeScript >= 5.5).
              ;; This elides the need for @types/* packages in the build environment.
              (invoke "tsc" "--noCheck")
              ;; Replicate the 'copy-assets' npm script:
              ;;   src/db/schema.sql        → dist/db/schema.sql
              ;;   src/extraction/wasm/*.wasm → dist/extraction/wasm/*.wasm
              ;; The six vendored .wasm grammars (pascal, scala, lua, luau,
              ;; csharp, r) are loaded at runtime via __dirname-relative paths
              ;; rather than require.resolve, so they must live inside dist/.
              (invoke "node" "-e"
                      (string-append
                       "const fs=require('fs');"
                       "fs.mkdirSync('dist/db',{recursive:true});"
                       "fs.copyFileSync('src/db/schema.sql','dist/db/schema.sql');"
                       "fs.mkdirSync('dist/extraction/wasm',{recursive:true});"
                       "fs.readdirSync('src/extraction/wasm')"
                       ".filter(f=>f.endsWith('.wasm'))"
                       ".forEach(f=>"
                       "fs.copyFileSync('src/extraction/wasm/'+f,"
                       "'dist/extraction/wasm/'+f))"))
              ;; Ensure the entry point is executable before node-build-system
              ;; creates the $out/bin symlink.
              (chmod "dist/bin/codegraph.js" #o755)))

          ;; Replace the symlink node-build-system creates at $out/bin/codegraph
          ;; with a shell wrapper that:
          ;;   • passes --liftoff-only to Node (disables V8 turboshaft WASM JIT)
          ;;   • sets CODEGRAPH_TELEMETRY=0 unless the user has overridden it
          (add-after 'install 'wrap-binary
            (lambda* (#:key outputs #:allow-other-keys)
              (let* ((out      (assoc-ref outputs "out"))
                     (bin      (string-append out "/bin/codegraph"))
                     (script   (string-append
                                out
                                "/lib/node_modules/@colbymchenry/codegraph"
                                "/dist/bin/codegraph.js"))
                     ;; Resolved at gexp-lowering time; the store path is
                     ;; embedded as a literal so the gc scanner keeps node-lts
                     ;; in the closure of the codegraph package.
                     (node-bin #$(file-append node-lts "/bin/node")))
                ;; Remove the node-build-system symlink; replace with wrapper.
                (delete-file bin)
                (call-with-output-file bin
                  (lambda (port)
                    (display
                     (string-append
                      "#!/bin/sh\n"
                      "# codegraph wrapper — generated by Guix.\n"
                      "#\n"
                      "# --liftoff-only disables the V8 turboshaft WASM JIT, preventing\n"
                      "# Zone OOM crashes when compiling large tree-sitter grammars on\n"
                      "# Node >= 22.  Because the flag is already in process.execArgv,\n"
                      "# processHasWasmRuntimeFlags() returns true and the in-process\n"
                      "# re-exec in relaunchWithWasmRuntimeFlagsIfNeeded is skipped.\n"
                      "#\n"
                      "# CODEGRAPH_TELEMETRY defaults to 0 (anonymous telemetry off).\n"
                      "# Override from your shell: CODEGRAPH_TELEMETRY=1 codegraph ...\n"
                      "# Full opt-in: unset CODEGRAPH_TELEMETRY before running.\n"
                      "CODEGRAPH_TELEMETRY=\"${CODEGRAPH_TELEMETRY:-0}\"\n"
                      "export CODEGRAPH_TELEMETRY\n"
                      ;; --disable-warning=ExperimentalWarning silences Node's
                      ;; per-invocation "SQLite is an experimental feature" notice
                      ;; (node:sqlite is load-bearing here and stable enough for us).
                      "exec " node-bin
                      " --liftoff-only --disable-warning=ExperimentalWarning "
                      script " \"$@\"\n")
                     port)))
                (chmod bin #o755)))))))
    (inputs
     ;; Runtime Node.js dependencies.  node-build-system symlinks each into
     ;; $out/lib/node_modules/@colbymchenry/codegraph/node_modules/ so that
     ;; Node's require() resolution finds them relative to dist/bin/codegraph.js.
     (list node-commander-14.0.3
           node-ignore-7.0.5
           node-picomatch-4.0.3
           node-sisteransi-1.0.5
           node-fast-string-truncated-width-3.0.3
           node-fast-string-width-3.0.2
           node-fast-wrap-ansi-0.2.0
           node-clack-core-1.3.0
           node-clack-prompts-1.3.0
           node-tree-sitter-wasms-0.1.13    ; out/*.wasm grammars for 20+ languages
           node-web-tree-sitter-0.25.10     ; WASM runtime + tree-sitter.wasm
           node-jsonc-parser))              ; reused from (gnu packages node-xyz)
    (native-inputs
     ;; Build-time only.  node-typescript provides `tsc` on PATH during the
     ;; build phase; it is not linked into the installed node_modules.
     (list node-typescript))
    (home-page "https://github.com/colbymchenry/codegraph")
    (synopsis "Local code-intelligence CLI: tree-sitter parsing + SQLite knowledge graph")
    (description
     "CodeGraph builds a local code-knowledge graph for any source tree.
It parses source files using tree-sitter WebAssembly grammars (over 20
languages) and stores the resulting symbol graph in a local SQLite database
via Node's built-in @code{node:sqlite}, with no native compilation step and
no network access at runtime.

The @command{codegraph} CLI exposes symbol search, caller/callee graph
traversal, affected-test analysis, and natural-language context assembly.
It is designed as the structural-memory backend for AI coding agents,
reducing redundant file reads by providing pre-indexed semantic navigation.")
    (license license:expat)))
