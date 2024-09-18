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
    [GroupRef],
    [Name]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]

-- SELECT * FROM @Pipelines

---------------------------------------------------------------- MappingSets --
DECLARE @MappingSets TABLE
(
    PrimKey UNIQUEIDENTIFIER, -- not null
    Name NVARCHAR(128), -- not null
    -- todo add "Description"
    MappingType NVARCHAR(128), -- not null: { 'ValueMapping' | 'Renaming' }
    TableName NVARCHAR(128) -- not null
)
INSERT INTO @MappingSets
(
    PrimKey,
    Name,
    MappingType,
    TableName
)
SELECT
    PrimKey = newid(),
    Name = [MappingSetID],
    [MappingType] = case
        WHEN MappingSetID LIKE '%Mapping' THEN 'Mapping'
        WHEN MappingSetID LIKE '%Renaming' THEN 'Renaming'
        ELSE MappingType
    END,
    TableName = [TargetTable]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
GROUP BY
    MappingSetID,
    TargetTable,
    MappingType

-- SELECT * FROM @MappingSets

------------------------------------------------------- PipelinesMappingSets --
DECLARE @PipelinesMappingSets TABLE
(
    GroupRef UNIQUEIDENTIFIER, -- not null
    MappingSetRef UNIQUEIDENTIFIER, -- not null
    PriorityOrder INT -- not null: default = 1 // used to support dependencies (e.g., DCS_Domain value is needed)
)
INSERT INTO @PipelinesMappingSets
SELECT
    GroupRef,
    MappingSetRef = MS.PrimKey,
    PriorityOrder = 1 -- this would get set by hand
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
    join @MappingSets MS
        on MS.Name = GFM.MappingSetID
GROUP BY
    GroupRef,
    MS.PrimKey

-- SELECT * FROM @PipelinesMappingSets

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
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
GROUP BY
    FromValue,
    CriteriaValue1,
    CriteriaValue2,
    ToValue

-- SELECT * FROM @ValueMappings

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
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
GROUP BY
    FromField,
    CriteriaField1,
    CriteriaField2,
    ToField

-- SELECT * FROM @FieldMappings

-------------------------------------------------------- MappingSetsMappings --
DECLARE @MappingSetsMappings TABLE
(
    MappingSetRef UNIQUEIDENTIFIER, -- not null
    FieldMappingRef UNIQUEIDENTIFIER, -- not null
    ValueMappingRef UNIQUEIDENTIFIER -- null
)
INSERT INTO @MappingSetsMappings
(
    MappingSetRef,
    FieldMappingRef,
    ValueMappingRef
)
SELECT
    MappingSetRef = (
        select Primkey
        from @MappingSets MS
        where
            MS.Name = GFM.MappingSetID
        and MS.TableName = GFM.TargetTable
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
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM

-------------------------------------------------------------------------------
-------------------------------------------------------- Reassemble and Test --
-------------------------------------------------------------------------------
/*
 * Original Mapping
 */
SELECT
    CriteriaField1,
    CriteriaField2,
    CriteriaValue1,
    CriteriaValue2,
    -- Description, -- todo: add this in
    FromField,
    FromValue,
    GroupRef,
    MappingSetID,
    -- MappingSetValueID, -- not used in the refactored version
    MappingType,
    Name,
    PriorityOrder,
    -- Required, -- todo: add this in
    TargetTable,
    ToField,
    ToValue
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
order by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14

/*
 * Refactored Mapping
 */
select
    FM.InputFieldTwo,
    FM.InputFieldThree,
    VM.InputValueTwo,
    VM.InputValueThree,
    -- Description, -- todo: add this in
    FM.InputFieldOne,
    VM.InputValueOne,
    P.PrimKey,
    MappingSetName = MS.Name,
    -- MappingSetValueID, -- this does not exist
    MS.MappingType,
    PiplelineName = P.Name,
    PMS.PriorityOrder,
    -- Required, -- todo: add this in
    MS.TableName,
    FM.OutputField,
    VM.OutputValue
from
    @Pipelines P
    join @PipelinesMappingSets PMS
        on PMS.GroupRef = P.PrimKey
    join @MappingSets MS
        on MS.PrimKey = PMS.MappingSetRef
    join @MappingSetsMappings MSM
        on MSM.MappingSetRef = PMS.MappingSetRef
    join @ValueMappings VM
        on VM.PrimKey = MSM.ValueMappingRef
    join @FieldMappings FM
        on FM.PrimKey = MSM.FieldMappingRef
order by
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
