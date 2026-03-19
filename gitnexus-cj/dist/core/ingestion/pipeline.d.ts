import { PipelineProgress, PipelineResult } from '../../types/pipeline.js';
export interface PipelineOptions {
    /** Skip MRO, community detection, and process extraction for faster test runs. */
    skipGraphPhases?: boolean;
}
export declare const runPipelineFromRepo: (repoPath: string, onProgress: (progress: PipelineProgress) => void, options?: PipelineOptions) => Promise<PipelineResult>;
