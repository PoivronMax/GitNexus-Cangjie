#!/usr/bin/env node
/**
 * Root bin for `npx github:owner/repo gitnexus-cj …`.
 * npm exec resolves executables from this package's `bin` field; workspace bins
 * alone are not enough. Import by package name so `node_modules/gitnexus-cj`
 * (built by `prepare` in that workspace) is used after install.
 */
process.env.GITNEXUS_PROGRAM_NAME ??= 'gitnexus-cj';
await import('gitnexus-cj/dist/cli/index.js');
