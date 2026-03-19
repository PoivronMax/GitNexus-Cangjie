# GitNexus-Cangjie

The Cangjie-compatible fork of GitNexus 1.4.7

**Graph-powered code intelligence.** Index any codebase into a knowledge graph and work with it through the **CLI**.

[![npm version](https://img.shields.io/npm/v/gitnexus.svg)](https://www.npmjs.com/package/gitnexus)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/License-PolyForm%20Noncommercial-blue.svg)](https://polyformproject.org/licenses/noncommercial/1.0.0/)

---

## This repository

| Path | Purpose |
|------|---------|
| **`gitnexus-cj/`** | npm workspace package **`gitnexus-cj`** — CLI and multi-language indexing (including **Cangjie** `.cj`). Self-contained; no separate `gitnexus` dependency. See [`gitnexus-cj/README.md`](./gitnexus-cj/README.md). |

### Develop from a clone

Root **`package.json`** declares an npm **workspace** for **`gitnexus-cj`** only. From the **repo root**, a local install pulls the full engine (Cangjie + native parsers):

```bash
npm install
npm exec gitnexus-cj -- --help
```

To work only on the package:

```bash
cd gitnexus-cj && npm install && npm run build
```

(Or stay at root and use `npm run build --workspace=gitnexus-cj`.)

### Recommended: global CLI

From **`gitnexus-cj/`** (needs **C++20** when native `tree-sitter` builds on Node 22+):

```bash
cd gitnexus-cj
export CXXFLAGS='-std=c++20'
sudo npm install -g .
```

If `sudo` drops environment variables and the build fails, use `sudo -E npm install -g .` or `sudo env CXXFLAGS='-std=c++20' npm install -g .`.

Then run the CLI from any directory (use `--` before subcommands and their flags):

```bash
npm exec gitnexus-cj -- analyze
# …other subcommands the same way
```

After a global install, you can also invoke the binary directly as `gitnexus-cj` if it is on your `PATH`.

---

## Why?

AI coding tools don't understand your codebase structure. They edit a function without knowing 47 other functions depend on it. GitNexus fixes this by **precomputing every dependency, call chain, and relationship** into a queryable graph.

## Quick Start

Install **`gitnexus-cj`** globally as in [Recommended: global CLI](#recommended-global-cli), then index a repo:

```bash
npm exec gitnexus-cj -- analyze
```

That walks the tree, parses with Tree-sitter, and writes the knowledge graph under **`.gitnexus/`** in the project.

## How It Works

GitNexus builds a complete knowledge graph of your codebase through a multi-phase indexing pipeline:

1. **Structure** — Walks the file tree and maps folder/file relationships
2. **Parsing** — Extracts functions, classes, methods, and interfaces using Tree-sitter ASTs
3. **Resolution** — Resolves imports and function calls across files with language-aware logic
4. **Clustering** — Groups related symbols into functional communities
5. **Processes** — Traces execution flows from entry points through call chains
6. **Search** — Builds hybrid search indexes for fast retrieval

The result is a **LadybugDB graph database** stored locally in `.gitnexus/` with full-text search and semantic embeddings.

## CLI Commands

```bash
gitnexus-cj analyze [path]           # Index a repository (or update stale index)
gitnexus-cj analyze --force          # Force full re-index
gitnexus-cj analyze --embeddings     # Enable embedding generation (slower, better search)
gitnexus-cj analyze --verbose        # Log skipped files when parsers are unavailable
gitnexus-cj list                     # List all indexed repositories
gitnexus-cj status                   # Show index status for current repo
gitnexus-cj clean                    # Delete index for current repo
gitnexus-cj clean --all --force      # Delete all indexes
gitnexus-cj wiki [path]              # Generate LLM-powered docs from knowledge graph
gitnexus-cj wiki --model <model>     # Wiki with custom LLM model (default: gpt-4o-mini)
```

With **`npm exec`**: `npm exec gitnexus-cj -- <subcommand> …` (see [Recommended: global CLI](#recommended-global-cli)).

## Multi-Repo Support

GitNexus supports indexing multiple repositories. Each `gitnexus-cj analyze` registers the repo in a global registry (`~/.gitnexus/registry.json`).

## Supported Languages

TypeScript, JavaScript, Python, Java, C, C++, C#, Go, Rust, PHP, Kotlin, Swift, Ruby, **Cangjie (`.cj`)** (via **`gitnexus-cj`** when built from this repo)

### Language Feature Matrix

| Language | Imports | Named Bindings | Exports | Heritage | Type Annotations | Constructor Inference | Config | Frameworks | Entry Points |
|----------|---------|----------------|---------|----------|-----------------|---------------------|--------|------------|-------------|
| TypeScript | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| JavaScript | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ |
| Python | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Java | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ |
| Kotlin | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ |
| C# | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Go | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Rust | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ |
| PHP | ✓ | ✓ | ✓ | — | ✓ | ✓ | ✓ | ✓ | ✓ |
| Ruby | ✓ | — | ✓ | ✓ | — | ✓ | — | ✓ | ✓ |
| Swift | — | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| C | — | — | ✓ | — | ✓ | ✓ | — | ✓ | ✓ |
| C++ | — | — | ✓ | ✓ | ✓ | ✓ | — | ✓ | ✓ |
| Cangjie | ✓ | — | ✓ | ✓ | ✓ | ✓ | — | — | ✓ |

**Imports** — cross-file import resolution · **Named Bindings** — `import { X as Y }` / re-export tracking · **Exports** — public/exported symbol detection · **Heritage** — class inheritance, interfaces, mixins · **Type Annotations** — explicit type extraction for receiver resolution · **Constructor Inference** — infer receiver type from constructor calls (`self`/`this` resolution included for all languages) · **Config** — language toolchain config parsing (tsconfig, go.mod, etc.) · **Frameworks** — AST-based framework pattern detection · **Entry Points** — entry point scoring heuristics

## Requirements

- Node.js >= 18
- Git repository (uses git for commit tracking)

### Building `gitnexus-cj/` from source (native `tree-sitter`)

The **`gitnexus`** package builds **`tree-sitter` 0.25** from source (no prebuilds). On **Node.js 22+**, V8 headers expect **C++20**. If `npm install` fails while compiling `tree-sitter`, run:

```bash
export CXXFLAGS='-std=c++20'
npm install
```

**Global:** see [Recommended: global CLI](#recommended-global-cli).

Or, from **`gitnexus-cj/`**: `npm run install:with-cpp20`. **Cangjie** (`tree-sitter-cangjie`) targets ABI **language version 15**, which requires **`tree-sitter` ≥ 0.25**.

Root **`.npmrc`** sets `legacy-peer-deps=true` so grammar packages’ peer ranges on older `tree-sitter` do not block install.

## Privacy

- All processing happens locally on your machine
- No code is sent to any server
- Index stored in `.gitnexus/` inside your repo (gitignored)
- Global registry at `~/.gitnexus/` stores only paths and metadata

## License

[PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/)

Free for non-commercial use. Contact for commercial licensing.
