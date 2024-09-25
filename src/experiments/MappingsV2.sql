
-------------------------------------------------------------------------------
----------------------------------------------- Break into normalized tables --
-------------------------------------------------------------------------------

------------------------------------------------------------------ Pipelines --
DECLARE @Pipelines TABLE
(
    PrimKey UNIQUEIDENTIFIER,
    Name NVARCHAR(128)
)
INSERT INTO @Pipelines
SELECT DISTINCT
    GroupRef,
    Name
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings

-- SELECT * FROM @Pipelines

------------------------------------------------------------------- Mappings --
DECLARE @Mappings TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    Name NVARCHAR(128), -- not null
    Description NVARCHAR(512),
    MappingType NVARCHAR(128), -- not null: { 'ValueMapping' | 'Renaming' | 'Function' ' Prefix' | 'Suffix' }
    PriorityOrder INT, -- not null: default = 1 // used to support dependencies (e.g., DCS_Domain value is needed)
    FunctionName NVARCHAR(128)
)
INSERT INTO @Mappings
(
    PrimKey,
    Name,
    Description,
    MappingType,
    PriorityOrder,
    FunctionName
)
SELECT
    PrimKey = newid(),
    Name = MappingSetID,
    Description,
    MappingType,
    -- MappingType = case -- worry about this later =)
    --     WHEN MappingSetID LIKE '%Mapping' THEN 'Mapping'
    --     WHEN MappingSetID LIKE '%Renaming' THEN 'Renaming'
    --     ELSE MappingType
    -- END,
    PriorityOrder,
    FunctionName = null
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings
GROUP BY
    MappingSetID,
    Description,
    MappingType,
    PriorityOrder

-- SELECT * FROM @Mappings

-------------------------------------------------------------- ValueMappings --
DECLARE @ValueMappings TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    InputValueOne NVARCHAR(max), -- null
    InputValueTwo NVARCHAR(max), -- null
    InputValueThree NVARCHAR(max), -- null
    OutputValue NVARCHAR(max) -- not null
)
INSERT INTO @ValueMappings
(
    PrimKey,
    InputValueOne,
    InputValueTwo,
    InputValueThree,
    OutputValue
)
SELECT
    PrimKey = newid(),
    FromValue,
    CriteriaValue1,
    CriteriaValue2,
    ToValue
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings GFM
GROUP BY
    FromValue,
    CriteriaValue1,
    CriteriaValue2,
    ToValue

-- SELECT * FROM @ValueMappings

------------------------------------------------------- MappingValueMappings --
DECLARE @MappingValueMappings TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    MappingsRef UNIQUEIDENTIFIER, -- not null
    ValueMappingRef UNIQUEIDENTIFIER -- not null
)
INSERT INTO @MappingValueMappings
(
    PrimKey,
    MappingsRef,
    ValueMappingRef
)
SELECT
    PrimKey = newid(),
    MappingSetRef = (
        select Primkey
        from @Mappings MS
        where
            MS.Name = GFM.MappingSetID
    ),
    ValueMappingRef = (
        select PrimKey
        from @ValueMappings VM
        where
            isnull(VM.InputValueOne, '') = isnull(GFM.FromValue, '')
            and isnull(VM.InputValueTwo, '') = isnull(GFM.CriteriaValue1, '')
            and isnull(VM.InputValueThree, '') = isnull(GFM.CriteriaValue2, '')
            and isnull(VM.OutputValue, '') = isnull(GFM.ToValue, '')
    )
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings GFM
GROUP BY
    MappingSetID,
    FromValue,
    CriteriaValue1,
    CriteriaValue2,
    ToValue

-- SELECT * FROM @MappingValueMappings

-------------------------------------------------------------- FieldMappings --
DECLARE @FieldMappings TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    InputFieldOne NVARCHAR(128), -- not null
    InputFieldTwo NVARCHAR(128), -- null
    InputFieldThree NVARCHAR(128), -- null
    OutputField NVARCHAR(128) -- not null
)
INSERT INTO @FieldMappings
(
    PrimKey,
    InputFieldOne,
    InputFieldTwo,
    InputFieldThree,
    OutputField
)
SELECT
    PrimKey = newid(),
    FromField,
    CriteriaField1,
    CriteriaField2,
    ToField
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings GFM
GROUP BY
    FromField,
    CriteriaField1,
    CriteriaField2,
    ToField

-- SELECT * FROM @FieldMappings

-------------------------------------------------------- MappingApplications --
-- todo: extract GroupRef (?)
DECLARE @MappingsInstances TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    GroupRef UNIQUEIDENTIFIER, -- not null
    TargetTable NVARCHAR(128), -- not null
    MappingRef UNIQUEIDENTIFIER, -- not null
    FieldMappingRef UNIQUEIDENTIFIER, -- not null
    Required BIT -- not null | default (0)
)
INSERT INTO @MappingsInstances
(
    PrimKey,
    GroupRef,
    TargetTable,
    MappingRef,
    FieldMappingRef,
    Required
)
SELECT
    PrimKey = newid(),
    GroupRef,
    TargetTable,
    MappingRef = (
        select PrimKey
        from @Mappings M
        where M.Name = GFM.MappingSetID
    ),
    FieldMappingRef = (
        select Primkey
        from @FieldMappings FM
        where
            isnull(FM.InputFieldOne, '') = isnull(GFM.FromField, '')
            and isnull(FM.InputFieldTwo, '') = isnull(GFM.CriteriaField1, '')
            and isnull(FM.InputFieldThree, '') = isnull(GFM.CriteriaField2, '')
            and isnull(FM.OutputField, '') = isnull(GFM.ToField, '')
    ),
    Required = GFM.Required
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings GFM
GROUP BY
    GroupRef,
    TargetTable,
    MappingSetID,
    FromField,
    CriteriaField1,
    CriteriaField2,
    ToField,
    Required

-------------------------------------------------------------------------------
-------------------------------------------------------- Reassemble and Test --
-------------------------------------------------------------------------------
/*
 * Original Mapping
 */
SELECT DISTINCT
    CriteriaField1,
    CriteriaField2,
    CriteriaValue1,
    CriteriaValue2,
    Description,
    FromField,
    FromValue,
    GroupRef,
    MappingSetID,
    -- MappingSetValueID, -- not used in the refactored version
    MappingType,
    Name,
    PriorityOrder,
    Required,
    TargetTable,
    ToField,
    ToValue
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
order by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16

/*
 * Refactored Mapping
 */
select
    FM.InputFieldTwo,
    FM.InputFieldThree,
    VM.InputValueTwo,
    VM.InputValueThree,
    Description,
    FM.InputFieldOne,
    VM.InputValueOne,
    P.PrimKey,
    MappingSetName = M.Name,
    -- MappingSetValueID, -- this does not exist
    M.MappingType,
    PiplelineName = P.Name,
    M.PriorityOrder,
    Required,
    MI.TargetTable,
    FM.OutputField,
    VM.OutputValue
from
    @Pipelines P
    join @MappingsInstances MI
        on MI.GroupRef = P.PrimKey
    join @Mappings M
        on M.PrimKey = MI.MappingRef
    join @MappingValueMappings MVM
        on MVM.MappingsRef = M.PrimKey
    join @ValueMappings VM
        on VM.PrimKey = MVM.ValueMappingRef
    join @FieldMappings FM
        on FM.PrimKey = MI.FieldMappingRef
order by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
