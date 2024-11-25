
declare
    @Param0 nvarchar(128) = N'DTS - DCS Rev Files Renaming',
    @FromField nvarchar(128) = 'fileComment',
    @ToField nvarchar(128) = 'DCS_FileDescription'

declare @mappingBase table (
    MappingSetID nvarchar(128),
    GroupRef uniqueidentifier,
    TargetTable nvarchar(128)
)
insert into @mappingBase
select distinct
    [MappingSetID],
    [GroupRef],
    [TargetTable]
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] with (nolock)
WHERE
    [MappingSetID] = @Param0  

/*
 * Add Mapping
 */
-- insert into dbo.atbl_Integrations_Configurations_FieldMappingSets_Subscribers
-- (
--     MappingSetID,
--     GroupRef,
--     TargetTable,
--     FromField,
--     ToField
-- )
select
    [MappingSetID],
    [GroupRef],
    [TargetTable],
    FromField = @FromField,
    ToField = @ToField
from
    @mappingBase

/*
 * Reference
 */
SELECT
[PrimKey],
[Created],
[CreatedBy],
[Updated],
[UpdatedBy],
[MappingSetID],
[GroupRef],
[TargetTable],
[CriteriaField1],
[CriteriaField2],
[FromField],
[ToField],
[Required],
[ConfigGroupName],
[HasConfigurationErrorsTargetTable],
[HasConfigurationErrorsCriteriaField1],
[HasConfigurationErrorsCriteriaField2],
[HasConfigurationErrorsFromField],
[HasConfigurationErrorsToField]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_Subscribers]
WHERE
    [MappingSetID] = @Param0
ORDER BY
    [ConfigGroupName],
    [TargetTable]
