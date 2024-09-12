declare @MappingSetIDs table (
    MappingSetID nvarchar(50)
)
insert into @MappingSetIDs
select MappingSetID
from [dbo].[atbl_Integrations_Configurations_FieldMappingSets] with (nolock)
where MappingSetID like 'UPP DTS - DCS%'

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
            [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] MappingValues with (nolock)
        where
            [MappingSetID] = Mappings.MappingSetID
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
            [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] MappingSubscribers with (nolock)
        where
            [MappingSetID] = Mappings.MappingSetID
        for
            json auto
    )
from
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets] Mappings with (nolock)
where
    [MappingSetID] in (
        select
            MappingSetID
        from
            @MappingSetIDs
    )
for
    json auto
