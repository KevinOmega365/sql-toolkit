
declare @GroupRef nvarchar(36) = N'fb36536c-db59-4926-952a-5868262a44a5'

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
output INSERTED.PrimKey
into @MappingSetsKeys
SELECT DISTINCT
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

-- select * from @MappingSetsKeys

-------------------------------------------------------------------------------

declare @PipelinesMappingSets table
(
    GroupRef uniqueidentifier, -- not null
    MappingRef uniqueidentifier, -- not null
    Priority int -- not null: default = 1
)

-------------------------------------------------------------------------------

declare @ValueMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputValueOne nvarchar(max), -- null
    InputValueTwo nvarchar(max), -- null
    InputValueThree nvarchar(max), -- null
    OutputValue nvarchar(max) -- not null
)

-------------------------------------------------------------------------------

declare @FieldMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputFieldOne nvarchar(128), -- not null
    InputFieldTwo nvarchar(128), -- null
    InputFieldThree nvarchar(128), -- null
    OutputField nvarchar(128) -- not null
)

-------------------------------------------------------------------------------

declare @MappingSetsMappings table
(
    MappingSetRef uniqueidentifier, -- not null
    FieldMappingRef uniqueidentifier, -- not null
    ValueMappingRef uniqueidentifier -- null
)

-------------------------------------------------------------------------------
