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
| **`gitnexus/`** | Published npm package **`gitnexus`** — CLI, MCP, indexing. **This fork** adds **Cangjie** (`.cj`) and pins **`tree-sitter` ≥ 0.25** for that grammar. |
| **`gitnexus-cj/`** | Published npm package **`gitnexus-cj`** — same CLI via `GITNEXUS_PROGRAM_NAME`; **depends on registry `gitnexus`** so installs from npm get the **official** engine (see [`gitnexus-cj/README.md`](./gitnexus-cj/README.md)). |
| **`gitnexus-web/`** | Browser UI — run `npm install` / `npm run dev` **inside that folder** (not part of the root npm workspace). |

### Develop from a clone

From the **repo root**:

```bash
npm install
npx gitnexus-cj --help
```

Root **`package.json`** uses workspace **`gitnexus-cj`** only, plus **`dependencies` / `overrides`: `gitnexus` → `file:./gitnexus`**, so the **full** `node_modules` tree for the local **`gitnexus/`** package is installed (Cangjie + native parsers). **`npx gitnexus`** / **`npx gitnexus-cj`** both resolve to that linked copy here.

To work only on core:

```bash
cd gitnexus && npm install && npm run build
```

---

## Why?

AI coding tools don't understand your codebase structure. They edit a function without knowing 47 other functions depend on it. GitNexus fixes this by **precomputing every dependency, call chain, and relationship** into a queryable graph.

**Three commands to give your AI agent full codebase awareness.**

## Quick Start

```bash
# Index your repo (run from repo root)
npx gitnexus analyze
```

Prefer an explicit **Cangjie**-oriented install name? Use [`gitnexus-cj`](https://www.npmjs.com/package/gitnexus-cj) — it runs the **same published `gitnexus`** engine from npm (no duplicate parsers); only the CLI name differs:

```bash
npx gitnexus-cj analyze
```

> **From npm:** `gitnexus-cj` depends on **registry `gitnexus`**, so other languages stay on the **official** stack. **Cangjie** in this repo is exercised when you **`npm install` at the monorepo root** (linked `file:./gitnexus`) or install/build **`gitnexus/`** directly.

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
claude mcp add gitnexus -- npx -y gitnexus@latest mcp
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

TypeScript, JavaScript, Python, Java, C, C++, C#, Go, Rust, PHP, Kotlin, Swift, Ruby, **Cangjie (`.cj`)** (in **`gitnexus/`** when built from this repo)

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

### Building `gitnexus/` from source (native `tree-sitter`)

The **`gitnexus`** package builds **`tree-sitter` 0.25** from source (no prebuilds). On **Node.js 22+**, V8 headers expect **C++20**. If `npm install` fails while compiling `tree-sitter`, run:

```bash
export CXXFLAGS='-std=c++20'
npm install
```

Or, from **`gitnexus/`**: `npm run install:with-cpp20`. **Cangjie** (`tree-sitter-cangjie`) targets ABI **language version 15**, which requires **`tree-sitter` ≥ 0.25**.

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
