
const mapping = {
    DCS_RevisionDate: 'revisionDate',
    DCS_Revision: 'revision',
    DCS_DocumentID: 'documentNumber',
    DCS_Step: 'proposedWorkflow',
    DCS_ContractorSupplierAcceptanceCode: 'contractorReturnCode',
    DCS_RevisionDate: 'revisionDate'
}

const template = {
    "MappingSetID": "UPP DTS - DCS Revisions Renaming",
    "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
    "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
    "CriteriaField1": "DCS_Domain",
    "FromField": "contractNumber",
    "ToField": "DCS_ContractNo",
    "Required": false
}

const output = Object.entries(mapping).map(([sink, source]) =>
{
    const o = Object.assign({}, template)
    o.FromField = source
    o.ToField = sink
    return o
})

console.log(JSON.stringify(output, null, 4))
