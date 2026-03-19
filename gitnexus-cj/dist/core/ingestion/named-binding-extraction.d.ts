import { SupportedLanguages } from '../../config/supported-languages.js';
import type { SymbolTable, SymbolDefinition } from './symbol-table.js';
import type { NamedImportMap } from './import-processor.js';
/**
 * Walk a named-binding re-export chain through NamedImportMap.
 *
 * When file A imports { User } from B, and B re-exports { User } from C,
 * the NamedImportMap for A points to B, but B has no User definition.
 * This function follows the chain: A→B→C until a definition is found.
 *
 * Returns the definitions found at the end of the chain, or null if the
 * chain breaks (missing binding, circular reference, or depth exceeded).
 * Max depth 5 to prevent infinite loops.
 *
 * @param allDefs Pre-computed `symbolTable.lookupFuzzy(name)` result — must be the
 *               complete unfiltered result. Passing a file-filtered subset will cause
 *               silent misses at depth=0 for non-aliased bindings.
 */
export declare function walkBindingChain(name: string, currentFilePath: string, symbolTable: SymbolTable, namedImportMap: NamedImportMap, allDefs: SymbolDefinition[]): SymbolDefinition[] | null;
/**
 * Extract named bindings from an import AST node.
 * Returns undefined if the import is not a named import (e.g., import * or default).
 *
 * TS: import { User, Repo as R } from './models'
 *   → [{local:'User', exported:'User'}, {local:'R', exported:'Repo'}]
 *
 * Python: from models import User, Repo as R
 *   → [{local:'User', exported:'User'}, {local:'R', exported:'Repo'}]
 */
export declare function extractNamedBindings(importNode: any, language: SupportedLanguages): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractTsNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractPythonNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractKotlinNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractRustNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractPhpNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractCsharpNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
export declare function extractJavaNamedBindings(importNode: any): {
    local: string;
    exported: string;
}[] | undefined;
