declare @MappingImportJson nvarchar(max) = '
[
    {
        "MappingSetID": "UPP DTS - DCS Revisions Renaming",
        "Description": "Column renaming from DTS fields to DCS columns for Revisions UPP (Munin)",
        "Values": [
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "MappingSetValueID": 1,
                "CriteriaValue1": "175",
                "CriteriaValue2": "DO_NOT_USE",
                "FromValue": "DO_NOT_USE",
                "ToValue": "DO_NOT_USE"
            }
        ],
        "Subscribers": [
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "revisionDate",
                "ToField": "DCS_RevisionDate",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "revision",
                "ToField": "DCS_Revision",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "documentNumber",
                "ToField": "DCS_DocumentID",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "proposedWorkflow",
                "ToField": "DCS_Step",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "contractorReturnCode",
                "ToField": "DCS_ContractorSupplierAcceptanceCode",
                "Required": false
            }
        ]
    }
]'

-- insert into [dbo].[atbl_Integrations_Configurations_FieldMappingSets]
-- (
--     MappingSetID,
--     Description
-- )
select
    MappingSetID = json_value(@MappingImportJson, '$[0].MappingSetID'),
    Description = json_value(@MappingImportJson, '$[0].Description')

-- insert into [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values]
-- (
--     MappingSetID,
--     MappingSetValueID,
--     CriteriaValue1,
--     CriteriaValue2,
--     FromValue,
--     ToValue
-- )
select
    MappingSetID = json_value(value, '$.MappingSetID'),
    MappingSetValueID = json_value(value, '$.MappingSetValueID'),
    CriteriaValue1 = json_value(value, '$.CriteriaValue1'),
    CriteriaValue2 = json_value(value, '$.CriteriaValue2'),
    FromValue = json_value(value, '$.FromValue'),
    ToValue = json_value(value, '$.ToValue')
from
    openjson(@MappingImportJson, '$[0].Values')


-- insert into [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers]
-- (
--     MappingSetID,
--     GroupRef,
--     TargetTable,
--     CriteriaField1,
--     FromField,
--     ToField,
--     Required
-- )
select
    MappingSetID = json_value(value, '$.MappingSetID'),
    GroupRef = json_value(value, '$.GroupRef'),
    TargetTable = json_value(value, '$.TargetTable'),
    CriteriaField1 = json_value(value, '$.CriteriaField1'),
    FromField = json_value(value, '$.FromField'),
    ToField = json_value(value, '$.ToField'),
    Required = json_value(value, '$.Required')
from
    openjson(@MappingImportJson, '$[0].Subscribers')