#!/usr/bin/env node
/**
 * Root bin for `npx github:<owner>/<repo> gitnexus-cj …` (same as gitnexus-cj/bin).
 */
process.env.GITNEXUS_PROGRAM_NAME ??= 'gitnexus-cj';
await import('gitnexus/dist/cli/index.js');
