declare @Pipelines table
{
    PrimKey
    Name
}

declare @PipelinesMappingSets table
{
    GroupRef uniqueidentifier,
    MappingRef uniqueidentifier,
    Priority int
}

declare @MappingSets table
{
    PrimKey
    Name
    Type
}

declare @ValueMappings table
{
    PrimKey
    KeyValueOne
    KeyValueTwo
    KeyValueThree
}