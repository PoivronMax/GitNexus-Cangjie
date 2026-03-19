#!/usr/bin/env node
/**
 * Thin entry: same CLI and indexing pipeline as `gitnexus`, including Cangjie (.cj).
 * Use this package when you want an explicit Cangjie-oriented install name (`npx gitnexus-cj`).
 */
process.env.GITNEXUS_PROGRAM_NAME ??= 'gitnexus-cj';
await import('gitnexus/dist/cli/index.js');
