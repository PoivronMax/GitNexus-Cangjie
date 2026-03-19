import type { SyntaxNode } from './utils.js';
import { SupportedLanguages } from '../../config/supported-languages.js';
import type { SymbolTable } from './symbol-table.js';
/**
 * Per-file scoped type environment: maps (scope, variableName) → typeName.
 * Scope-aware: variables inside functions are keyed by function name,
 * file-level variables use the '' (empty string) scope.
 *
 * Design constraints:
 * - Explicit-only: Tier 0 uses type annotations; Tier 1 infers from constructors
 * - Tier 2: single-pass assignment chain propagation in source order — resolves
 *   `const b = a` when `a` already has a type from Tier 0/1
 * - Scope-aware: function-local variables don't collide across functions
 * - Conservative: complex/generic types extract the base name only
 * - Per-file: built once, used for receiver resolution, then discarded
 */
export type TypeEnv = Map<string, Map<string, string>>;
/**
 * Per-file type environment with receiver resolution.
 * Built once per file via `buildTypeEnv`, used for receiver-type filtering,
 * then discarded. Encapsulates scope-aware type lookup and self/this/super
 * AST resolution behind a single `.lookup()` method.
 */
export interface TypeEnvironment {
    /** Look up a variable's resolved type, with self/this/super AST resolution. */
    lookup(varName: string, callNode: SyntaxNode): string | undefined;
    /** Unverified cross-file constructor bindings for SymbolTable verification. */
    readonly constructorBindings: readonly ConstructorBinding[];
    /** Raw per-scope type bindings — for testing and debugging. */
    readonly env: TypeEnv;
}
export declare const buildTypeEnv: (tree: {
    rootNode: SyntaxNode;
}, language: SupportedLanguages, symbolTable?: SymbolTable) => TypeEnvironment;
/**
 * Unverified constructor binding: a `val x = Callee()` pattern where we
 * couldn't confirm the callee is a class (because it's defined in another file).
 * The caller must verify `calleeName` against the SymbolTable before trusting.
 */
export interface ConstructorBinding {
    /** Function scope key (matches TypeEnv scope keys) */
    scope: string;
    /** Variable name that received the constructor result */
    varName: string;
    /** Name of the callee (potential class constructor) */
    calleeName: string;
    /** Enclosing class name when callee is a method on a known receiver (e.g. $this) */
    receiverClassName?: string;
}
