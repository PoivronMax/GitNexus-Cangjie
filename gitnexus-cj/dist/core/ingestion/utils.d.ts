import type Parser from 'tree-sitter';
import { SupportedLanguages } from '../../config/supported-languages.js';
/** Tree-sitter AST node. Re-exported for use across ingestion modules. */
export type SyntaxNode = Parser.SyntaxNode;
/**
 * Ordered list of definition capture keys for tree-sitter query matches.
 * Used to extract the definition node from a capture map.
 */
export declare const DEFINITION_CAPTURE_KEYS: readonly ["definition.method", "definition.function", "definition.class", "definition.interface", "definition.struct", "definition.enum", "definition.namespace", "definition.module", "definition.trait", "definition.impl", "definition.type", "definition.const", "definition.static", "definition.typedef", "definition.macro", "definition.union", "definition.property", "definition.record", "definition.delegate", "definition.annotation", "definition.constructor", "definition.template"];
/** Extract the definition node from a tree-sitter query capture map. */
export declare const getDefinitionNodeFromCaptures: (captureMap: Record<string, any>) => SyntaxNode | null;
/**
 * Node types that represent function/method definitions across languages.
 * Used to find the enclosing function for a call site.
 */
export declare const FUNCTION_NODE_TYPES: Set<string>;
/**
 * Node types for standard function declarations that need C/C++ declarator handling.
 * Used by extractFunctionName to determine how to extract the function name.
 */
export declare const FUNCTION_DECLARATION_TYPES: Set<string>;
/**
 * Built-in function/method names that should not be tracked as call targets.
 * Covers JS/TS, Python, Kotlin, C/C++, PHP, Swift standard library functions.
 */
export declare const BUILT_IN_NAMES: Set<string>;
/** Check if a name is a built-in function or common noise that should be filtered out */
export declare const isBuiltInOrNoise: (name: string) => boolean;
/** AST node types that represent a class-like container (for HAS_METHOD edge extraction) */
export declare const CLASS_CONTAINER_TYPES: Set<string>;
export declare const CONTAINER_TYPE_TO_LABEL: Record<string, string>;
/** Walk up AST to find enclosing class/struct/interface/impl, return its generateId or null.
 *  For Go method_declaration nodes, extracts receiver type (e.g. `func (u *User) Save()` → User struct). */
export declare const findEnclosingClassId: (node: any, filePath: string) => string | null;
/**
 * Extract function name and label from a function_definition or similar AST node.
 * Handles C/C++ qualified_identifier (ClassName::MethodName) and other language patterns.
 */
export declare const extractFunctionName: (node: SyntaxNode) => {
    funcName: string | null;
    label: string;
};
/**
 * Yield control to the event loop so spinners/progress can render.
 * Call periodically in hot loops to prevent UI freezes.
 */
export declare const yieldToEventLoop: () => Promise<void>;
/**
 * Find a child of `childType` within a sibling node of `siblingType`.
 * Used for Kotlin AST traversal where visibility_modifier lives inside a modifiers sibling.
 */
export declare const findSiblingChild: (parent: any, siblingType: string, childType: string) => any | null;
/**
 * Map file extension to SupportedLanguage enum
 */
export declare const getLanguageFromFilename: (filename: string) => SupportedLanguages | null;
export interface MethodSignature {
    parameterCount: number | undefined;
    returnType: string | undefined;
}
/**
 * Extract parameter count and return type text from an AST method/function node.
 * Works across languages by looking for common AST patterns.
 */
export declare const extractMethodSignature: (node: SyntaxNode | null | undefined) => MethodSignature;
/**
 * Count direct arguments for a call expression across common tree-sitter grammars.
 * Returns undefined when the argument container cannot be located cheaply.
 */
export declare const countCallArguments: (callNode: SyntaxNode | null | undefined) => number | undefined;
type CallForm = 'free' | 'member' | 'constructor';
/**
 * Infer whether a captured call site is a free call, member call, or constructor.
 * Returns undefined if the form cannot be determined.
 *
 * Works by inspecting the AST structure between callNode (@call) and nameNode (@call.name).
 * No tree-sitter query changes needed — the distinction is in the node types.
 */
export declare const inferCallForm: (callNode: SyntaxNode, nameNode: SyntaxNode) => CallForm | undefined;
export declare const extractReceiverName: (nameNode: SyntaxNode) => string | undefined;
/**
 * Extract the raw receiver AST node for a member call.
 * Unlike extractReceiverName, this returns the receiver node regardless of its type —
 * including call_expression / method_invocation nodes that appear in chained calls
 * like `svc.getUser().save()`.
 *
 * Returns undefined when the call is not a member call or when no receiver node
 * can be found (e.g. top-level free calls).
 */
export declare const extractReceiverNode: (nameNode: SyntaxNode) => SyntaxNode | undefined;
export declare const isVerboseIngestionEnabled: () => boolean;
/** Node types representing call expressions across supported languages. */
export declare const CALL_EXPRESSION_TYPES: Set<string>;
/**
 * Hard limit on chain depth to prevent runaway recursion.
 * For `a.b().c().d()`, the chain has depth 2 (b and c before d).
 */
export declare const MAX_CHAIN_DEPTH = 3;
/**
 * Walk a receiver AST node that is itself a call expression, accumulating the
 * chain of intermediate method names up to MAX_CHAIN_DEPTH.
 *
 * For `svc.getUser().save()`, called with the receiver of `save` (getUser() call):
 *   returns { chain: ['getUser'], baseReceiverName: 'svc' }
 *
 * For `a.b().c().d()`, called with the receiver of `d` (c() call):
 *   returns { chain: ['b', 'c'], baseReceiverName: 'a' }
 */
export declare function extractCallChain(receiverCallNode: SyntaxNode): {
    chain: string[];
    baseReceiverName: string | undefined;
} | undefined;
/** One step in a mixed receiver chain. */
export type MixedChainStep = {
    kind: 'field' | 'call';
    name: string;
};
/**
 * Walk a receiver AST node that may interleave field accesses and method calls,
 * building a unified chain of steps up to MAX_CHAIN_DEPTH.
 *
 * For `svc.getUser().address.save()`, called with the receiver of `save`
 * (`svc.getUser().address`, a field access node):
 *   returns { chain: [{ kind:'call', name:'getUser' }, { kind:'field', name:'address' }],
 *             baseReceiverName: 'svc' }
 *
 * For `user.getAddress().city.getName()`, called with receiver of `getName`
 * (`user.getAddress().city`):
 *   returns { chain: [{ kind:'call', name:'getAddress' }, { kind:'field', name:'city' }],
 *             baseReceiverName: 'user' }
 *
 * Pure field chains and pure call chains are special cases (all steps same kind).
 */
export declare function extractMixedChain(receiverNode: SyntaxNode): {
    chain: MixedChainStep[];
    baseReceiverName: string | undefined;
} | undefined;
export {};
