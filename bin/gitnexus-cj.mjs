#!/usr/bin/env node
/**
 * Root bin for `npx github:<owner>/<repo> gitnexus-cj …` — delegates to workspace package.
 */
process.env.GITNEXUS_PROGRAM_NAME ??= 'gitnexus-cj';
await import('../gitnexus-cj/dist/cli/index.js');
