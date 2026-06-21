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
;;; 11 Node.js runtime dependency packages for CodeGraph.  All are
;;; pure-JavaScript or WASM-data blobs; none require a native build step.
;;; node-jsonc-parser (3.3.1) is an exact version match in upstream Guix
;;; (gnu packages node-xyz) and is reused directly — it is NOT redefined here.
;;;
;;; Dependency graph (leaves first):
;;;
;;;   commander, ignore, picomatch, sisteransi
;;;   fast-string-truncated-width
;;;     └─ fast-string-width
;;;          └─ (used by fast-wrap-ansi and clack/prompts)
;;;   fast-wrap-ansi         (← fast-string-width)
;;;   @clack/core            (← fast-wrap-ansi, sisteransi)
;;;   @clack/prompts         (← @clack/core, fast-string-width, fast-wrap-ansi, sisteransi)
;;;   tree-sitter-wasms      (self-reference in package.json stripped in phase)
;;;   web-tree-sitter        (no runtime JS deps)
;;;
;;; SHA-256 hashes are zero-placeholder.  Fill each with:
;;;   guix download <tarball-url>
;;; or read the "actual hash" line from the `guix build` error output.
;;;
;;; Code:

(define-module (guix-codegraph packages node-codegraph-deps)
  #:use-module (gnu packages node)
  #:use-module (gnu packages node-xyz)
  #:use-module (guix build-system node)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages))


;; ---------------------------------------------------------------------------
;; node-commander — command-line interface framework
;; ---------------------------------------------------------------------------

(define-public node-commander-14.0.3
  (package
    (name "node-commander")
    (version "14.0.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/commander/-/commander-14.0.3.tgz")
       (sha256
        (base32
         "0v1gv6m55pdh5rqyjyxv6zy4iv7rl6yxhh0kn17343qfa0y70jaq"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (home-page "https://github.com/tj/commander.js#readme")
    (synopsis "Complete solution for Node.js command-line interfaces")
    (description
     "Commander is a complete solution for Node.js command-line interfaces,
inspired by Ruby's commander.  It provides declarative support for
subcommands, options, arguments, and auto-generated help text.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-ignore — .gitignore-style file pattern matching
;; ---------------------------------------------------------------------------

(define-public node-ignore-7.0.5
  (package
    (name "node-ignore")
    (version "7.0.5")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/ignore/-/ignore-7.0.5.tgz")
       (sha256
        (base32
         "1062hjm3bgg9013nvl33mmz3cchvcjhndq6gj61sgzazvqwnqbg8"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (home-page "https://github.com/kaelzhang/node-ignore#readme")
    (synopsis "Manages and filters file paths against .gitignore rules")
    (description
     "Ignore is a manager and filter for .gitignore files.  It parses
.gitignore-style patterns and determines which paths should be
excluded, following the same semantics as git itself.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-picomatch — fast glob and minimatch-compatible pattern matching
;; ---------------------------------------------------------------------------

(define-public node-picomatch-4.0.3
  (package
    (name "node-picomatch")
    (version "4.0.3")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/picomatch/-/picomatch-4.0.3.tgz")
       (sha256
        (base32
         "174a20y03whm667xdl8zvbsxv3k8jxs53kmxldj7grlx2pyi2qmd"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (home-page "https://github.com/micromatch/picomatch#readme")
    (synopsis "Blazing-fast and accurate glob-pattern matching library")
    (description
     "Picomatch is an extremely fast, accurate, and zero-dependency glob
matching library.  It matches strings against one or more glob patterns
using the same rules as bash, zsh, fish, and many other shells.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-sisteransi — raw ANSI escape code sequences
;; ---------------------------------------------------------------------------

(define-public node-sisteransi-1.0.5
  (package
    (name "node-sisteransi")
    (version "1.0.5")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/sisteransi/-/sisteransi-1.0.5.tgz")
       (sha256
        (base32
         "1cvl75j0rn1nzsan50rl8nq0px0njyqa2z3nl7jisq8m8fr2jkcy"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (home-page "https://github.com/terkelg/sisteransi#readme")
    (synopsis "Raw ANSI escape sequences for terminal cursor control")
    (description
     "Sisteransi provides a minimal collection of raw ANSI escape codes for
terminal cursor movement, erasing, and other standard control sequences.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-fast-string-truncated-width — string width helper (leaf dep)
;; ---------------------------------------------------------------------------

(define-public node-fast-string-truncated-width-3.0.3
  (package
    (name "node-fast-string-truncated-width")
    (version "3.0.3")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/fast-string-truncated-width/-/"
             "fast-string-truncated-width-3.0.3.tgz"))
       (sha256
        (base32
         "1cay7d986m3yy4rkh8ybcn54n4jjj10j1fjxxm9v8w1l88swxnmm"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (home-page "https://www.npmjs.com/package/fast-string-truncated-width")
    (synopsis "Get the visible width of a Unicode string up to a given length")
    (description
     "A fast helper for computing the visible display width of a Unicode
string, stopping early once a given character limit is reached.  Used
internally by fast-string-width.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-fast-string-width — Unicode visible-width computation
;; ---------------------------------------------------------------------------

(define-public node-fast-string-width-3.0.2
  (package
    (name "node-fast-string-width")
    (version "3.0.2")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/fast-string-width/-/"
             "fast-string-width-3.0.2.tgz"))
       (sha256
        (base32
         "0akmnc694qnsl8vdmiargfh9va9wd1i5zzr7l9ahx6r0vw9z3nkj"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (inputs
     (list node-fast-string-truncated-width-3.0.3))
    (home-page "https://www.npmjs.com/package/fast-string-width")
    (synopsis "Fast computation of visible Unicode string display width")
    (description
     "Computes the visible column width of a Unicode string by summing the
display width of each code point.  Handles wide CJK characters, zero-width
combiners, and ANSI escape sequences correctly.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-fast-wrap-ansi — fast ANSI-aware string line wrapping
;; ---------------------------------------------------------------------------

(define-public node-fast-wrap-ansi-0.2.0
  (package
    (name "node-fast-wrap-ansi")
    (version "0.2.0")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/fast-wrap-ansi/-/"
             "fast-wrap-ansi-0.2.0.tgz"))
       (sha256
        (base32
         "0y5jiyvkc33f6qk489xyk342m08j2hc584y9hlvi3h4x36vf2lzv"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (inputs
     (list node-fast-string-width-3.0.2))
    (home-page "https://www.npmjs.com/package/fast-wrap-ansi")
    (synopsis "Fast ANSI-aware word wrapping of terminal strings")
    (description
     "Wraps strings containing ANSI escape sequences at a given column width
without breaking escape codes mid-sequence.  Used by clack's interactive
prompt rendering.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-clack-core — low-level interactive prompt primitives (@clack/core)
;; ---------------------------------------------------------------------------

(define-public node-clack-core-1.3.0
  (package
    (name "node-clack-core")
    (version "1.3.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/@clack/core/-/core-1.3.0.tgz")
       (sha256
        (base32
         "0wxr9vfqm3ax2wrj9hwbk22ckm9n50chy7a1rcxd6raqn9q0yyzn"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (inputs
     (list node-fast-wrap-ansi-0.2.0
           node-sisteransi-1.0.5))
    (home-page
     "https://github.com/bombshell-dev/clack/tree/main/packages/core#readme")
    (synopsis "Low-level primitives for building interactive CLI prompts")
    (description
     "Clack/core provides the low-level building blocks — prompts, spinners,
and input handling — for implementing custom interactive command-line
applications.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-clack-prompts — high-level prompt components (@clack/prompts)
;; ---------------------------------------------------------------------------

(define-public node-clack-prompts-1.3.0
  (package
    (name "node-clack-prompts")
    (version "1.3.0")
    (source
     (origin
       (method url-fetch)
       (uri "https://registry.npmjs.org/@clack/prompts/-/prompts-1.3.0.tgz")
       (sha256
        (base32
         "0dvhw509hdydqjs2pi3iw67mglrhi9366b43r5xb30gmkvz30nwm"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies))))))))
    (inputs
     (list node-clack-core-1.3.0
           node-fast-string-width-3.0.2
           node-fast-wrap-ansi-0.2.0
           node-sisteransi-1.0.5))
    (home-page
     "https://github.com/bombshell-dev/clack/tree/main/packages/prompts#readme")
    (synopsis "Effortlessly beautiful interactive command-line prompts")
    (description
     "Clack/prompts provides ready-made interactive components — text input,
confirmation, select, multi-select, spinner, and grouped tasks — built on
@clack/core for building polished CLI experiences with minimal boilerplate.")
    (license license:expat)))


;; ---------------------------------------------------------------------------
;; node-tree-sitter-wasms — prebuilt tree-sitter WASM grammar collection
;; ---------------------------------------------------------------------------

(define-public node-tree-sitter-wasms-0.1.13
  (package
    (name "node-tree-sitter-wasms")
    (version "0.1.13")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/tree-sitter-wasms/-/"
             "tree-sitter-wasms-0.1.13.tgz"))
       (sha256
        (base32
         "1l0d6miba0mnx1lf2bgfg4lyfm6vfhafz3253gvfi196pfdlm9b6"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   ;; The 0.1.x npm tarball carries a self-referential runtime
                   ;; dependency ("tree-sitter-wasms": "^0.1.11") — an artifact
                   ;; of the bundling strategy used to ship the full .wasm set.
                   ;; Remove it so the install phase does not try to resolve the
                   ;; package against itself.
                   (add-after 'patch-dependencies 'fix-dependencies
                     (lambda _
                       (modify-json
                        (delete-dev-dependencies)
                        (delete-dependencies
                         '("tree-sitter-wasms")))))))))
    (home-page "https://github.com/nicolo-ribaudo/tree-sitter-wasms#readme")
    (synopsis "Prebuilt WebAssembly tree-sitter grammar files for many languages")
    (description
     "A collection of prebuilt WebAssembly (.wasm) grammar files for
tree-sitter, covering languages including TypeScript, JavaScript, Python,
Go, Rust, Java, C, C++, PHP, Ruby, Swift, Kotlin, Dart, and more.  Loaded
at runtime by web-tree-sitter without any native compilation step.")
    ;; Upstream declares The Unlicense for the packaging; individual grammars
    ;; carry their own licenses (MIT, Apache-2.0, etc.).
    (license license:unlicense)))


;; ---------------------------------------------------------------------------
;; node-web-tree-sitter — WebAssembly bindings for the tree-sitter parser
;; ---------------------------------------------------------------------------

(define-public node-web-tree-sitter-0.25.10
  (package
    (name "node-web-tree-sitter")
    (version "0.25.10")
    (source
     (origin
       (method url-fetch)
       (uri (string-append
             "https://registry.npmjs.org/web-tree-sitter/-/"
             "web-tree-sitter-0.25.10.tgz"))
       (sha256
        (base32
         "03ryac94sasaikam6sjipc9ybi6936p644v7fgxlasayr9x4adk6"))))
    (build-system node-build-system)
    (arguments
     (list #:tests? #f
           #:phases
           (gexp (modify-phases %standard-phases
                   (delete 'build)
                   ;; @types/emscripten is a peerDependency (type-only); npm 7+
                   ;; auto-installs peerDeps, so strip it too — delete-dependencies
                   ;; removes from all dep fields, not just "dependencies".
                   (add-after 'patch-dependencies 'delete-dev-dependencies
                     (lambda _
                       (modify-json (delete-dev-dependencies)
                                    (delete-dependencies
                                     '("@types/emscripten")))))))))
    (home-page
     "https://github.com/tree-sitter/tree-sitter/tree/master/lib/binding_web#readme")
    (synopsis "WebAssembly bindings for the tree-sitter incremental parser")
    (description
     "Web-tree-sitter provides the WebAssembly-compiled tree-sitter runtime
for use in Node.js (and browsers) without any native compilation.  Language
grammars are loaded as separate .wasm files at runtime via Parser.init() and
Language.load().")
    (license license:expat)))
