#!/usr/bin/env node
/**
 * Build tree-sitter-cangjie native addon from source.
 *
 * tree-sitter-cangjie >= 1.0.5 ships binding.gyp under bindings/node/ and
 * sets its install script to a no-op (echo).  After npm pulls the package
 * from git we need to compile the C sources ourselves.
 *
 * This script:
 *  1. Looks for the package in node_modules.
 *  2. Checks whether the addon is already loadable.
 *  3. If not, runs `node-gyp rebuild` inside bindings/node/.
 */
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

function findPackageDir() {
  // In npm workspaces the package may be hoisted to the root node_modules.
  // Walk up from this script until we find the right node_modules.
  let dir = path.resolve(__dirname, '..');
  for (let i = 0; i < 5; i++) {
    const candidate = path.join(dir, 'node_modules', 'tree-sitter-cangjie');
    if (fs.existsSync(path.join(candidate, 'package.json'))) return candidate;
    dir = path.dirname(dir);
  }
  return null;
}

const PKG_DIR = findPackageDir();
if (!PKG_DIR) {
  console.log('[build-tree-sitter-cangjie] Package not found, skipping');
  process.exit(0);
}

const BINDING_DIR = path.join(PKG_DIR, 'bindings', 'node');
const BINDING_GYP = path.join(BINDING_DIR, 'binding.gyp');
const BUILD_ARTIFACT = path.join(BINDING_DIR, 'build', 'Release', 'tree_sitter_cangjie.node');

const LEGACY_BINDING_GYP = path.join(PKG_DIR, 'binding.gyp');
const LEGACY_BUILD = path.join(PKG_DIR, 'build', 'Release');

function addonAlreadyBuilt() {
  // New layout
  if (fs.existsSync(BUILD_ARTIFACT)) return true;
  // Legacy layout
  if (fs.existsSync(LEGACY_BUILD)) {
    const files = fs.readdirSync(LEGACY_BUILD);
    if (files.some(f => f.endsWith('.node'))) return true;
  }
  return false;
}

function build() {
  if (addonAlreadyBuilt()) {
    console.log('[build-tree-sitter-cangjie] Native addon already built, skipping');
    return;
  }

  // Determine which layout we're dealing with
  const useNewLayout = fs.existsSync(BINDING_GYP);
  const useLegacyLayout = !useNewLayout && fs.existsSync(LEGACY_BINDING_GYP);

  if (!useNewLayout && !useLegacyLayout) {
    console.warn('[build-tree-sitter-cangjie] No binding.gyp found; skipping native build');
    return;
  }

  const cwd = useNewLayout ? BINDING_DIR : PKG_DIR;
  console.log(`[build-tree-sitter-cangjie] Building native addon in ${cwd} ...`);

  const env = { ...process.env };
  // Node.js 24+ requires C++20 for native addons (v8 headers use C++20 features).
  const major = parseInt(process.versions.node.split('.')[0], 10);
  if (major >= 24 && !env.CXXFLAGS) {
    env.CXXFLAGS = '-std=c++20';
  }

  try {
    execSync('npx --yes node-gyp rebuild', {
      cwd,
      stdio: 'inherit',
      env,
    });
    console.log('[build-tree-sitter-cangjie] Build succeeded');
  } catch (err) {
    console.error('[build-tree-sitter-cangjie] Build failed:', err.message);
    console.error('[build-tree-sitter-cangjie] Ensure you have a C/C++ toolchain installed (Xcode CLT / build-essential / MSVC).');
    process.exit(1);
  }
}

try {
  build();
} catch (e) {
  console.error('[build-tree-sitter-cangjie]', e.message);
  process.exit(1);
}
