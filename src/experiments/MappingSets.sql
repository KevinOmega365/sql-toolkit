
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @Subsea uniqueidentifier = 'fb36536c-db59-4926-952a-5868262a44a5',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Subsea

-------------------------------------------------------------------------------

declare @Pipelines table
(
    PrimKey uniqueidentifier,
    Name nvarchar(128)
)
insert into @Pipelines
SELECT DISTINCT
    [GroupRef],
    [Name]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
WHERE
    [GroupRef] = @GroupRef

select * from @Pipelines

-------------------------------------------------------------------------------

declare @MappingSetsKeys table
(
    MappingSetRef uniqueidentifier
)

declare @MappingSets table
(
    PrimKey uniqueidentifier, -- not null
    Name nvarchar(128), -- not null
    MappingType nvarchar(128), -- not null: { 'ValueMapping' | 'Renaming' }
    TableName nvarchar(128) -- not null
)
insert into @MappingSets
(
    PrimKey,
    Name,
    MappingType,
    TableName
)
output
    INSERTED.PrimKey
into
    @MappingSetsKeys
SELECT
    PrimKey = newid(),
    Name = [MappingSetID],
    [MappingType] = case
        when MappingSetID like '%Mapping' then 'Mapping'
        when MappingSetID like '%Renaming' then 'Renaming'
        else MappingType
    end,
    TableName = [TargetTable]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
WHERE
    [GroupRef] = @GroupRef
GROUP BY
    MappingSetID,
    TargetTable,
    MappingType

select * from @MappingSets

-------------------------------------------------------------------------------

declare @PipelinesMappingSets table
(
    GroupRef uniqueidentifier, -- not null
    MappingRef uniqueidentifier, -- not null
    Priority int -- not null: default = 1 // used to support dependencies (e.g., DCS_Domain value is needed)
)
insert into @PipelinesMappingSets
select
    GroupRef,
    MappingRef = MS.PrimKey,
    ROW_NUMBER() OVER (ORDER BY MS.PrimKey) -- this would get set by hand
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
    join @MappingSets MS
        on MS.Name = GFM.MappingSetID
WHERE
    [GroupRef] = @GroupRef
GROUP BY
    GroupRef,
    MS.PrimKey

select * from @PipelinesMappingSets

-------------------------------------------------------------------------------

declare @ValueMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputValueOne nvarchar(max), -- null
    InputValueTwo nvarchar(max), -- null
    InputValueThree nvarchar(max), -- null
    OutputValue nvarchar(max) -- not null
)
insert into @ValueMappings
(
    PrimKey,
    InputValueOne,
    InputValueTwo,
    InputValueThree,
    OutputValue
)
select
    PrimKey = newid(),
    CriteriaValue1,
    CriteriaValue2,
    FromValue,
    ToValue
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
WHERE
    [GroupRef] = @GroupRef
GROUP BY
    CriteriaValue1,
    CriteriaValue2,
    FromValue,
    ToValue

-- select * from @ValueMappings

-------------------------------------------------------------------------------

declare @FieldMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputFieldOne nvarchar(128), -- not null
    InputFieldTwo nvarchar(128), -- null
    InputFieldThree nvarchar(128), -- null
    OutputField nvarchar(128) -- not null
) 
insert into @FieldMappings
(
    PrimKey,
    InputFieldOne,
    InputFieldTwo,
    InputFieldThree,
    OutputField
)
select
    PrimKey = newid(),
    CriteriaField1,
    CriteriaField2,
    FromField,
    ToField
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings] GFM
WHERE
    [GroupRef] = @GroupRef
GROUP BY
    CriteriaField1,
    CriteriaField2,
    FromField,
    ToField

-- select * from @FieldMappings

-------------------------------------------------------------------------------

declare @MappingSetsMappings table
(
    MappingSetRef uniqueidentifier, -- not null
    FieldMappingRef uniqueidentifier, -- not null
    ValueMappingRef uniqueidentifier -- null
)

-- todo: it!

-------------------------------------------------------------------------------
