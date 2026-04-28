export const createSymbolTable = () => {
    // 1. File-Specific Index — stores full SymbolDefinition for O(1) lookupExactFull
    // Structure: FilePath -> (SymbolName -> SymbolDefinition)
    const fileIndex = new Map();
    // 2. Global Reverse Index (The "Backup")
    // Structure: SymbolName -> [List of Definitions]
    const globalIndex = new Map();
    // 3. Lazy Callable Index — populated on first lookupFuzzyCallable call.
    // Structure: SymbolName -> [Callable Definitions]
    // Only Function, Method, Constructor symbols are indexed.
    let callableIndex = null;
    // 4. Eagerly-populated Field/Property Index — keyed by "ownerNodeId\0fieldName".
    // Only Property symbols with ownerId and declaredType are indexed.
    const fieldByOwner = new Map();
    // 5. NodeId reverse index — for O(1) lookupByNodeId.
    // Enables ownerId resolution for any Method/Constructor/Property given only its nodeId.
    const nodeIdIndex = new Map();
    const CALLABLE_TYPES = new Set(['Function', 'Method', 'Constructor']);
    const add = (filePath, name, nodeId, type, metadata) => {
        const def = {
            nodeId,
            filePath,
            type,
            ...(metadata?.parameterCount !== undefined ? { parameterCount: metadata.parameterCount } : {}),
            ...(metadata?.returnType !== undefined ? { returnType: metadata.returnType } : {}),
            ...(metadata?.declaredType !== undefined ? { declaredType: metadata.declaredType } : {}),
            ...(metadata?.ownerId !== undefined ? { ownerId: metadata.ownerId } : {}),
        };
        // A. Add to File Index (shared reference — zero additional memory)
        if (!fileIndex.has(filePath)) {
            fileIndex.set(filePath, new Map());
        }
        fileIndex.get(filePath).set(name, def);
        // A2. Add to nodeId reverse index (shared reference)
        nodeIdIndex.set(nodeId, def);
        // B. Properties go to fieldByOwner index only — skip globalIndex to prevent
        // namespace pollution for common names like 'id', 'name', 'type'.
        // Index ALL properties (even without declaredType) so write-access tracking
        // can resolve field ownership for dynamically-typed languages (Ruby, JS).
        if (type === 'Property' && metadata?.ownerId) {
            fieldByOwner.set(`${metadata.ownerId}\0${name}`, def);
            // Still add to fileIndex above (for lookupExact), but skip globalIndex
            return;
        }
        // C. Add to Global Index (same object reference)
        if (!globalIndex.has(name)) {
            globalIndex.set(name, []);
        }
        globalIndex.get(name).push(def);
        // D. Invalidate the lazy callable index only when adding callable types
        if (CALLABLE_TYPES.has(type)) {
            callableIndex = null;
        }
    };
    const lookupExact = (filePath, name) => {
        return fileIndex.get(filePath)?.get(name)?.nodeId;
    };
    const lookupExactFull = (filePath, name) => {
        return fileIndex.get(filePath)?.get(name);
    };
    const lookupFuzzy = (name) => {
        return globalIndex.get(name) || [];
    };
    const lookupFuzzyCallable = (name) => {
        if (!callableIndex) {
            // Build the callable index lazily on first use
            callableIndex = new Map();
            for (const [symName, defs] of globalIndex) {
                const callables = defs.filter(d => CALLABLE_TYPES.has(d.type));
                if (callables.length > 0)
                    callableIndex.set(symName, callables);
            }
        }
        return callableIndex.get(name) ?? [];
    };
    const lookupFieldByOwner = (ownerNodeId, fieldName) => {
        return fieldByOwner.get(`${ownerNodeId}\0${fieldName}`);
    };
    const lookupByNodeId = (nodeId) => {
        return nodeIdIndex.get(nodeId);
    };
    const getStats = () => ({
        fileCount: fileIndex.size,
        globalSymbolCount: globalIndex.size
    });
    const clear = () => {
        fileIndex.clear();
        globalIndex.clear();
        callableIndex = null;
        fieldByOwner.clear();
        nodeIdIndex.clear();
    };
    return { add, lookupExact, lookupExactFull, lookupFuzzy, lookupFuzzyCallable, lookupFieldByOwner, lookupByNodeId, getStats, clear };
};
