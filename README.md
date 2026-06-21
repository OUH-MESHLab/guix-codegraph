# guix-codegraph

A [Guix](https://guix.gnu.org) channel that provides declarative, reproducible
package definitions for [CodeGraph](https://github.com/colbymchenry/codegraph)
— a tree-sitter + SQLite local code-intelligence CLI that powers semantic
code-knowledge-graph capabilities for AI agents.

CodeGraph indexes a codebase into a local SQLite database (via Node's built-in
`node:sqlite`) and exposes fast symbol search, caller/callee graphs, and
context-building queries — with zero network calls at runtime.

## Contents

| Module                                          | What it provides                                           |
|-------------------------------------------------|------------------------------------------------------------|
| `(guix-codegraph packages codegraph)`           | The `codegraph` package (Node, built from git source)      |
| `(guix-codegraph packages node-codegraph-deps)` | 11 npm runtime dependency packages                         |

## Adding the channel

Add to `~/.config/guix/channels.scm`:

```scheme
(cons* (channel
         (name 'guix-codegraph)
         (url "https://github.com/OUH-MESHLab/guix-codegraph"))
       %default-channels)
```

## Building

```bash
# Build codegraph directly from a local checkout of this channel
guix build -L ~/src/guix-codegraph \
  -e '(@ (guix-codegraph packages codegraph) codegraph)'

# Run it
guix shell -L ~/src/guix-codegraph codegraph -- codegraph --version
```

## Notes

- Built from git source; TypeScript is compiled with `tsc` at Guix build time.
- The wrapper binary passes `--liftoff-only` to Node so the V8 turboshaft WASM
  JIT is bypassed for tree-sitter grammar compilation (prevents Zone OOM on
  Node ≥ 22 with large grammars).
- Anonymous telemetry is **off by default** via `CODEGRAPH_TELEMETRY=0` in the
  wrapper.  Override with `CODEGRAPH_TELEMETRY=1` or `DO_NOT_TRACK=0` in your
  shell if you want to opt in.
- Node engine constraint: `>=20 <25`.  Uses upstream `node-lts` (22.x).

## License

Copyright © 2026 Rafael Palomar \<rafael.palomar@ous-research.no\>

The channel itself (Scheme packaging code) is licensed under the GNU General
Public License version 3 or later.  CodeGraph upstream is MIT.
