/**
 * PHP PSR-4 import resolution.
 * Handles use-statement resolution via composer.json autoload mappings.
 */
import type { SuffixIndex } from './utils.js';
/** PHP Composer PSR-4 autoload config */
export interface ComposerConfig {
    /** Map of namespace prefix -> directory (e.g., "App\\" -> "app/") */
    psr4: Map<string, string>;
}
/**
 * Resolve a PHP use-statement import path using PSR-4 mappings.
 * e.g. "App\Http\Controllers\UserController" -> "app/Http/Controllers/UserController.php"
 */
export declare function resolvePhpImport(importPath: string, composerConfig: ComposerConfig | null, allFiles: Set<string>, normalizedFileList: string[], allFileList: string[], index?: SuffixIndex): string | null;
