# gitnexus-cj

CLI entry **`gitnexus-cj`** that delegates to the **`gitnexus`** package (same commands, MCP, indexing).

## What gets installed

| Where you install | `gitnexus` resolved from | Cangjie (`.cj`) |
|-------------------|--------------------------|-----------------|
| **`npm install gitnexus-cj`** (registry) | [Official `gitnexus` on npm](https://www.npmjs.com/package/gitnexus) | When upstream ships it |
| **This monorepo** (`npm install` at repo root) | **`file:./gitnexus`** via root `overrides` | Your local fork under `gitnexus/` |

Published **`gitnexus-cj` does not bundle** a fork of the engine — it depends on **`gitnexus@^1.4.7`** so users get the **same multi-language stack** as installing `gitnexus` directly. That avoids this repo’s experimental `tree-sitter` / grammar pins affecting everyone who only wanted a Cangjie-flavored CLI name.

## Usage

```bash
npx gitnexus-cj --help
gitnexus-cj analyze ./my-cangjie-repo
```

The program name in `--help` is **`gitnexus-cj`** (via `GITNEXUS_PROGRAM_NAME`).

## Requirements

Match **gitnexus** (Node 18+). Any native build notes from the [gitnexus README](https://github.com/abhigyanpatwari/GitNexus/blob/main/gitnexus/README.md) apply to the resolved `gitnexus` install.

## Monorepo development (Huawei / Cangjie fork)

From the **repository root**:

```bash
npm install
```

The workspace lists **only `gitnexus-cj`** (so you do not treat `gitnexus` as a second publishable workspace package). The root **`package.json`** also declares **`"gitnexus": "file:./gitnexus"`** so npm installs the **full dependency tree** for the local engine (npm does not install nested deps for link-only overrides alone). **`overrides`** keeps **`gitnexus-cj` → `gitnexus`** on that same `file:./gitnexus` copy. Result: one `npm install` at the repo root, official **`gitnexus` is not** pulled from the registry here — you run the fork under `gitnexus/`.

To work on **`gitnexus/`** alone without the workspace:

```bash
cd gitnexus && npm install && npm run build
```

## Publishing

1. Publish **`gitnexus`** (official or your fork) at the version range declared in `gitnexus-cj/package.json`.
2. Publish **`gitnexus-cj`** — do **not** ship root `overrides`; consumers resolve **`gitnexus`** from the registry.
