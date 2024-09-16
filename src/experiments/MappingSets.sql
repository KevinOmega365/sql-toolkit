declare @Pipelines table
(
    PrimKey uniqueidentifier,
    Name nvarchar(128)
)

declare @PipelinesMappingSets table
(
    GroupRef uniqueidentifier, -- not null
    MappingRef uniqueidentifier, -- not null
    Priority int -- not null: default = 1
)

declare @MappingSets table
(
    PrimKey uniqueidentifier, -- not null
    Name nvarchar(128), -- not null
    MappingType nvarchar(128), -- not null: { 'ValueMapping' | 'Renaming' }
    TableName nvarchar(128) -- not null
)

declare @ValueMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputValueOne nvarchar(max), -- null
    InputValueTwo nvarchar(max), -- null
    InputValueThree nvarchar(max), -- null
    OutputValue nvarchar(max) -- not null
)

declare @FieldMappings table
(
    PrimKey uniqueidentifier, -- not null
    InputFieldOne nvarchar(128), -- not null
    InputFieldTwo nvarchar(128), -- null
    InputFieldThree nvarchar(128), -- null
    OutputField nvarchar(128) -- not null
)

declare @MappingSetsMappings table
(
    MappingSetRef uniqueidentifier, -- not null
    FieldMappingRef uniqueidentifier, -- not null
    ValueMappingRef uniqueidentifier -- null
)
