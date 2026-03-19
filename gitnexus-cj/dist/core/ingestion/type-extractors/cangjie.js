const noopDecl = () => { };
const noopParam = () => { };
/** Minimal type env for Cangjie — static inference can be added later. */
export const typeConfig = {
    declarationNodeTypes: new Set(),
    extractDeclaration: noopDecl,
    extractParameter: noopParam,
};
