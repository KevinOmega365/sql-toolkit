declare @MappingSetID nvarchar(50) = N'UPP DTS - DCS Documents Renaming'

select
    [MappingSetID],
    [Description],
    [Values] = (
        select
            [MappingSetID],
            [MappingSetValueID],
            [CriteriaValue1],
            [CriteriaValue2],
            [FromValue],
            [ToValue]
        from
            [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] with (nolock)
        where
            [MappingSetID] = @MappingSetID
        for
            json auto
    ),
    [Subscribers] = (
        select
            [MappingSetID],
            [GroupRef],
            [TargetTable],
            [CriteriaField1],
            [CriteriaField2],
            [FromField],
            [ToField],
            [Required]
        from
            [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] with (nolock)
        where
            [MappingSetID] = @MappingSetID
        for
            json auto
    )
from
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets] with (nolock)
where
    [MappingSetID] = @MappingSetID
for
    json auto
