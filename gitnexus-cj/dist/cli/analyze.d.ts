/**
 * Analyze Command
 *
 * Indexes a repository and stores the knowledge graph in .gitnexus/
 */
export interface AnalyzeOptions {
    force?: boolean;
    embeddings?: boolean;
    skills?: boolean;
    verbose?: boolean;
}
export declare const analyzeCommand: (inputPath?: string, options?: AnalyzeOptions) => Promise<void>;
