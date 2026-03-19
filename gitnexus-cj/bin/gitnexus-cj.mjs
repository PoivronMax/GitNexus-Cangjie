#!/usr/bin/env node
/**
 * Published CLI entry for `gitnexus-cj` (same engine as upstream GitNexus, Cangjie-first package name).
 */
process.env.GITNEXUS_PROGRAM_NAME ??= 'gitnexus-cj';
await import('../dist/cli/index.js');
