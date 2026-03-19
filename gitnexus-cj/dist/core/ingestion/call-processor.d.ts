import { KnowledgeGraph } from '../graph/types.js';
import { ASTCache } from './ast-cache.js';
import type { ResolutionContext } from './resolution-context.js';
import type { ExtractedCall, ExtractedAssignment, ExtractedHeritage, ExtractedRoute, FileConstructorBindings } from './workers/parse-worker.js';
export declare const processCalls: (graph: KnowledgeGraph, files: {
    path: string;
    content: string;
}[], astCache: ASTCache, ctx: ResolutionContext, onProgress?: (current: number, total: number) => void) => Promise<ExtractedHeritage[]>;
/**
 * Fast path: resolve pre-extracted call sites from workers.
 * No AST parsing — workers already extracted calledName + sourceId.
 */
export declare const processCallsFromExtracted: (graph: KnowledgeGraph, extractedCalls: ExtractedCall[], ctx: ResolutionContext, onProgress?: (current: number, total: number) => void, constructorBindings?: FileConstructorBindings[]) => Promise<void>;
/**
 * Resolve pre-extracted field write assignments to ACCESSES {reason: 'write'} edges.
 * Accepts optional constructorBindings for return-type-aware receiver inference,
 * mirroring processCallsFromExtracted's verified binding lookup.
 */
export declare const processAssignmentsFromExtracted: (graph: KnowledgeGraph, assignments: ExtractedAssignment[], ctx: ResolutionContext, constructorBindings?: FileConstructorBindings[]) => void;
/**
 * Resolve pre-extracted Laravel routes to CALLS edges from route files to controller methods.
 */
export declare const processRoutesFromExtracted: (graph: KnowledgeGraph, extractedRoutes: ExtractedRoute[], ctx: ResolutionContext, onProgress?: (current: number, total: number) => void) => Promise<void>;
