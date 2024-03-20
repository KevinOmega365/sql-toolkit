declare @MappingImportJson nvarchar(max) = '
[
    {
        "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
        "Description": "DocumentGroup mapping for Documents UPP (Munin)",
        "Values": [
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "MappingSetValueID": 1,
                "CriteriaValue1": "UPP",
                "FromValue": "ENGDOC",
                "ToValue": "ENGINEERING"
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "MappingSetValueID": 2,
                "CriteriaValue1": "UPP",
                "FromValue": "ENGDWG",
                "ToValue": "ENGINEERING"
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "MappingSetValueID": 3,
                "CriteriaValue1": "UPP",
                "FromValue": "SUPDOC",
                "ToValue": "SUPPLIER"
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "MappingSetValueID": 4,
                "CriteriaValue1": "UPP",
                "FromValue": "SUPDWG",
                "ToValue": "SUPPLIER"
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "MappingSetValueID": 5,
                "CriteriaValue1": "UPP",
                "FromValue": "NONENS",
                "ToValue": "PROJECT DOCUMENT"
            }
        ],
        "Subscribers": [
            {
                "MappingSetID": "UPP DTS - DCS Documents DocumentGroup Mapping",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "documentGroup",
                "ToField": "DCS_DocumentGroup",
                "Required": false
            }
        ]
    },
    {
        "MappingSetID": "UPP DTS - DCS Documents Domain Mapping",
        "Description": "Domain mapping for Documents UPP (Munin)",
        "Values": [
            {
                "MappingSetID": "UPP DTS - DCS Documents Domain Mapping",
                "MappingSetValueID": 1,
                "FromValue": "UPP",
                "ToValue": "175"
            }
        ],
        "Subscribers": [
            {
                "MappingSetID": "UPP DTS - DCS Documents Domain Mapping",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "FromField": "facilityCode",
                "ToField": "DCS_Domain",
                "Required": true
            }
        ]
    },
    {
        "MappingSetID": "UPP DTS - DCS Documents Renaming",
        "Description": "Column renaming from DTS fields to DCS columns for Documents UPP (Munin)",
        "Values": [
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "MappingSetValueID": 1,
                "CriteriaValue1": "UPP",
                "CriteriaValue2": "DO_NOT_USE",
                "FromValue": "DO_NOT_USE",
                "ToValue": "DO_NOT_USE"
            }
        ],
        "Subscribers": [
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "contractNumber",
                "ToField": "DCS_ContractNo",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "disciplineCode",
                "ToField": "DCS_Discipline",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "documentNumber",
                "ToField": "DCS_DocumentID",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "documentTitle",
                "ToField": "DCS_Title",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "documentTypeShortCode",
                "ToField": "DCS_DocumentType",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "facilityCode",
                "ToField": "DCS_FacilityID",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "originatingContractor",
                "ToField": "DCS_OriginatorCompany",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Documents Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Documents",
                "CriteriaField1": "facilityCode",
                "FromField": "reviewClass",
                "ToField": "DCS_ReviewClass",
                "Required": false
            }
        ]
    },
    {
        "MappingSetID": "UPP DTS - DCS Rev Files Renaming",
        "Description": "Column renaming from DTS fields to DCS columns for Revisions-Files UPP (Munin)",
        "Values": [
            {
                "MappingSetID": "UPP DTS - DCS Rev Files Renaming",
                "MappingSetValueID": 1,
                "CriteriaValue1": "175",
                "CriteriaValue2": "DO_NOT_USE",
                "FromValue": "DO_NOT_USE",
                "ToValue": "DO_NOT_USE"
            }
        ],
        "Subscribers": [
            {
                "MappingSetID": "UPP DTS - DCS Rev Files Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_RevisionsFiles",
                "CriteriaField1": "DCS_Domain",
                "FromField": "documentNumber",
                "ToField": "DCS_DocumentID",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Rev Files Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_RevisionsFiles",
                "CriteriaField1": "DCS_Domain",
                "FromField": "fileSequenceNumber",
                "ToField": "DCS_SortOrder",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Rev Files Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_RevisionsFiles",
                "CriteriaField1": "DCS_Domain",
                "FromField": "revision",
                "ToField": "DCS_Revision",
                "Required": false
            }
        ]
    },
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
                "FromField": "contractorReturnCode",
                "ToField": "DCS_ContractorSupplierAcceptanceCode",
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
                "FromField": "revision",
                "ToField": "DCS_Revision",
                "Required": false
            },
            {
                "MappingSetID": "UPP DTS - DCS Revisions Renaming",
                "GroupRef": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
                "TargetTable": "ltbl_Import_DTS_DCS_Revisions",
                "CriteriaField1": "DCS_Domain",
                "FromField": "revisionDate",
                "ToField": "DCS_RevisionDate",
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
    MappingSetID = json_value(value, '$.MappingSetID'),
    Description = json_value(value, '$.Description')
from
    openjson(@MappingImportJson)

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
    MappingSetID = json_value(MappingValues.value, '$.MappingSetID'),
    MappingSetValueID = json_value(MappingValues.value, '$.MappingSetValueID'),
    CriteriaValue1 = json_value(MappingValues.value, '$.CriteriaValue1'),
    CriteriaValue2 = json_value(MappingValues.value, '$.CriteriaValue2'),
    FromValue = json_value(MappingValues.value, '$.FromValue'),
    ToValue = json_value(MappingValues.value, '$.ToValue')
from
    openjson(@MappingImportJson) Mapping
    cross apply openjson(Mapping.value, '$.Values') MappingValues


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
    MappingSetID = json_value(MappingSubscribers.value, '$.MappingSetID'),
    GroupRef = json_value(MappingSubscribers.value, '$.GroupRef'),
    TargetTable = json_value(MappingSubscribers.value, '$.TargetTable'),
    CriteriaField1 = json_value(MappingSubscribers.value, '$.CriteriaField1'),
    FromField = json_value(MappingSubscribers.value, '$.FromField'),
    ToField = json_value(MappingSubscribers.value, '$.ToField'),
    Required = json_value(MappingSubscribers.value, '$.Required')
from
    openjson(@MappingImportJson) Mapping
    cross apply openjson(Mapping.value, '$.Subscribers') MappingSubscribers