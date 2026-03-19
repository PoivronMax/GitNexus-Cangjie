# GitNexus

⚠️ **Notice:** GitNexus has **no** official cryptocurrency, token, or coin. Any asset using the GitNexus name on Pump.fun or elsewhere is **not** affiliated with this project.

**Graph-powered code intelligence for AI agents.** Index any codebase into a knowledge graph, then query it via MCP or CLI.

Works with **Cursor**, **Claude Code**, **Windsurf**, **Cline**, **OpenCode**, and any MCP-compatible tool.

[![npm version](https://img.shields.io/npm/v/gitnexus.svg)](https://www.npmjs.com/package/gitnexus)
[![License: PolyForm Noncommercial](https://img.shields.io/badge/License-PolyForm%20Noncommercial-blue.svg)](https://polyformproject.org/licenses/noncommercial/1.0.0/)

---

## This repository (monorepo)

| Path | Purpose |
|------|---------|
| **`gitnexus-cj/`** | npm workspace package **`gitnexus-cj`** — full CLI, MCP, and multi-language indexing (including **Cangjie** `.cj`). Self-contained; no separate `gitnexus` dependency. See [`gitnexus-cj/README.md`](./gitnexus-cj/README.md). |
| **`gitnexus-web/`** | Browser UI — run `npm install` / `npm run dev` **inside that folder** (not part of the root npm workspace). |

### Develop from a clone

From the **repo root**:

```bash
npm install
npx gitnexus-cj --help
```

Root **`package.json`** declares an npm **workspace** for **`gitnexus-cj`** only. One install pulls the full engine (Cangjie + native parsers).

To work only on the package:

```bash
cd gitnexus-cj && npm install && npm run build
```
(Or stay at root and use `npm run build --workspace=gitnexus-cj`.)

**Global install from a clone** (needs C++20 when native `tree-sitter` builds on Node 22+):

```bash
cd gitnexus-cj
export CXXFLAGS='-std=c++20'
sudo -E npm install -g "$(pwd)"
```

`sudo -E` preserves `CXXFLAGS` for the compile; otherwise use `sudo env CXXFLAGS='-std=c++20' npm install -g "$(pwd)"`.

### Run from GitHub (no clone)

`npx` / `npm exec` installs the **repo root** (workspace **`gitnexus-workspace`**). npm discovers the **`gitnexus-cj`** executable from the root **`package.json` → `bin`** (required by npm); that script imports the workspace package **`gitnexus-cj`** after install (`import('gitnexus-cj/dist/cli/index.js')`). The workspace’s **`prepare`** runs **`npm run build`**, which creates **`gitnexus-cj/dist/`** (not committed). A relative `../gitnexus-cj/dist/...` shim can fail in some install layouts; resolving by package name does not.

**Monorepo root** (workspaces + root `bin`):

```bash
npx github:Trenza1ore/GitNexus-Cangjie gitnexus-cj --help
npx github:Trenza1ore/GitNexus-Cangjie gitnexus-cj analyze /path/to/project
```

**Package only** (same CLI, tarball rooted at `gitnexus-cj/` — useful if you want a single-package install):

```bash
npx github:Trenza1ore/GitNexus-Cangjie#path:gitnexus-cj gitnexus-cj --help
```

Pin a branch or tag on the GitHub specifier (before `#path:` if you use it), e.g. `github:OWNER/REPO#main`.

The token **`gitnexus-cj`** after the specifier is the **npm bin name** from [`gitnexus-cj/package.json`](./gitnexus-cj/package.json). First install compiles native deps (e.g. `tree-sitter`); on Node 22+ you may need:

```bash
export CXXFLAGS='-std=c++20'
npx github:Trenza1ore/GitNexus-Cangjie gitnexus-cj analyze
```

Published builds: **`npx gitnexus-cj`** (see npm when this fork is published under that name).

---

## Why?

AI coding tools don't understand your codebase structure. They edit a function without knowing 47 other functions depend on it. GitNexus fixes this by **precomputing every dependency, call chain, and relationship** into a queryable graph.

**Three commands to give your AI agent full codebase awareness.**

## Quick Start

```bash
# Index your repo (run from repo root)
npx gitnexus analyze
```

> **From npm:** install **`gitnexus-cj`** for the full stack (all supported languages including Cangjie). This monorepo builds that package from **`gitnexus-cj/`**.

That's it. This indexes the codebase, installs agent skills, registers Claude Code hooks, and creates `AGENTS.md` / `CLAUDE.md` context files — all in one command.

To configure MCP for your editor, run `npx gitnexus setup` once — or set it up manually below.

`gitnexus setup` auto-detects your editors and writes the correct global MCP config. You only need to run it once.

### Editor Support

| Editor | MCP | Skills | Hooks (auto-augment) | Support |
|--------|-----|--------|---------------------|---------|
| **Claude Code** | Yes | Yes | Yes (PreToolUse) | **Full** |
| **Cursor** | Yes | Yes | — | MCP + Skills |
| **Windsurf** | Yes | — | — | MCP |
| **OpenCode** | Yes | Yes | — | MCP + Skills |

> **Claude Code** gets the deepest integration: MCP tools + agent skills + PreToolUse hooks that automatically enrich grep/glob/bash calls with knowledge graph context.

### Community Integrations

| Agent | Install | Source |
|-------|---------|--------|
| [pi](https://pi.dev) | `pi install npm:pi-gitnexus` | [pi-gitnexus](https://github.com/tintinweb/pi-gitnexus) |

## MCP Setup (manual)

If you prefer to configure manually instead of using `gitnexus setup`:

### Claude Code (full support — MCP + skills + hooks)

```bash
claude mcp add gitnexus -- npx gitnexus@latest mcp
```

### Cursor / Windsurf

Add to `~/.cursor/mcp.json` (global — works for all projects):

```json
{
  "mcpServers": {
    "gitnexus": {
      "command": "npx",
      "args": ["-y", "gitnexus@latest", "mcp"]
    }
  }
}
```

### OpenCode

Add to `~/.config/opencode/config.json`:

```json
{
  "mcp": {
    "gitnexus": {
      "command": "npx",
      "args": ["-y", "gitnexus@latest", "mcp"]
    }
  }
}
```

## How It Works

GitNexus builds a complete knowledge graph of your codebase through a multi-phase indexing pipeline:

1. **Structure** — Walks the file tree and maps folder/file relationships
2. **Parsing** — Extracts functions, classes, methods, and interfaces using Tree-sitter ASTs
3. **Resolution** — Resolves imports and function calls across files with language-aware logic
4. **Clustering** — Groups related symbols into functional communities
5. **Processes** — Traces execution flows from entry points through call chains
6. **Search** — Builds hybrid search indexes for fast retrieval

The result is a **LadybugDB graph database** stored locally in `.gitnexus/` with full-text search and semantic embeddings.

## MCP Tools

Your AI agent gets these tools automatically:

| Tool | What It Does | `repo` Param |
|------|-------------|--------------|
| `list_repos` | Discover all indexed repositories | — |
| `query` | Process-grouped hybrid search (BM25 + semantic + RRF) | Optional |
| `context` | 360-degree symbol view — categorized refs, process participation | Optional |
| `impact` | Blast radius analysis with depth grouping and confidence | Optional |
| `detect_changes` | Git-diff impact — maps changed lines to affected processes | Optional |
| `rename` | Multi-file coordinated rename with graph + text search | Optional |
| `cypher` | Raw Cypher graph queries | Optional |

> With one indexed repo, the `repo` param is optional. With multiple, specify which: `query({query: "auth", repo: "my-app"})`.

## MCP Resources

| Resource | Purpose |
|----------|---------|
| `gitnexus://repos` | List all indexed repositories (read first) |
| `gitnexus://repo/{name}/context` | Codebase stats, staleness check, and available tools |
| `gitnexus://repo/{name}/clusters` | All functional clusters with cohesion scores |
| `gitnexus://repo/{name}/cluster/{name}` | Cluster members and details |
| `gitnexus://repo/{name}/processes` | All execution flows |
| `gitnexus://repo/{name}/process/{name}` | Full process trace with steps |
| `gitnexus://repo/{name}/schema` | Graph schema for Cypher queries |

## MCP Prompts

| Prompt | What It Does |
|--------|-------------|
| `detect_impact` | Pre-commit change analysis — scope, affected processes, risk level |
| `generate_map` | Architecture documentation from the knowledge graph with mermaid diagrams |

## CLI Commands

```bash
gitnexus setup                    # Configure MCP for your editors (one-time)
gitnexus analyze [path]           # Index a repository (or update stale index)
gitnexus analyze --force          # Force full re-index
gitnexus analyze --embeddings     # Enable embedding generation (slower, better search)
gitnexus analyze --verbose        # Log skipped files when parsers are unavailable
gitnexus mcp                     # Start MCP server (stdio) — serves all indexed repos
gitnexus serve                   # Start local HTTP server (multi-repo) for web UI
gitnexus list                    # List all indexed repositories
gitnexus status                  # Show index status for current repo
gitnexus clean                   # Delete index for current repo
gitnexus clean --all --force     # Delete all indexes
gitnexus wiki [path]             # Generate LLM-powered docs from knowledge graph
gitnexus wiki --model <model>    # Wiki with custom LLM model (default: gpt-4o-mini)
```

## Multi-Repo Support

GitNexus supports indexing multiple repositories. Each `gitnexus analyze` registers the repo in a global registry (`~/.gitnexus/registry.json`). The MCP server serves all indexed repos automatically.

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

## Agent Skills

GitNexus ships with skill files that teach AI agents how to use the tools effectively:

- **Exploring** — Navigate unfamiliar code using the knowledge graph
- **Debugging** — Trace bugs through call chains
- **Impact Analysis** — Analyze blast radius before changes
- **Refactoring** — Plan safe refactors using dependency mapping

Installed automatically by both `gitnexus analyze` (per-repo) and `gitnexus setup` (global).

## Requirements

- Node.js >= 18
- Git repository (uses git for commit tracking)

### Building `gitnexus-cj/` from source (native `tree-sitter`)

The **`gitnexus`** package builds **`tree-sitter` 0.25** from source (no prebuilds). On **Node.js 22+**, V8 headers expect **C++20**. If `npm install` fails while compiling `tree-sitter`, run:

```bash
export CXXFLAGS='-std=c++20'
npm install
```

**Global:** from **`gitnexus-cj/`**, `export CXXFLAGS='-std=c++20'` then `sudo -E npm install -g "$(pwd)"` (see [Develop from a clone](#develop-from-a-clone)).

Or, from **`gitnexus-cj/`**: `npm run install:with-cpp20`. **Cangjie** (`tree-sitter-cangjie`) targets ABI **language version 15**, which requires **`tree-sitter` ≥ 0.25**.

Root **`.npmrc`** sets `legacy-peer-deps=true` so grammar packages’ peer ranges on older `tree-sitter` do not block install.

## Privacy

- All processing happens locally on your machine
- No code is sent to any server
- Index stored in `.gitnexus/` inside your repo (gitignored)
- Global registry at `~/.gitnexus/` stores only paths and metadata

## Web UI

GitNexus also has a browser-based UI at [gitnexus.vercel.app](https://gitnexus.vercel.app) — 100% client-side, your code never leaves the browser.

**Local:** from **`gitnexus-web/`**, run `npm install` and `npm run dev`. **Local backend mode:** run `gitnexus serve` and open the web UI — it can use your CLI-indexed repos over the HTTP API.

## License

[PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/)

Free for non-commercial use. Contact for commercial licensing.
