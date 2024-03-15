
declare @MappingSetID nvarchar(50)=N'UPP DTS - DCS Documents DocumentGroup Mapping'

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
    [Required]
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] with (nolock)
WHERE
    [MappingSetID] = @MappingSetID
ORDER BY
    [TargetTable]

SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [MappingSetID],
    [MappingSetValueID],
    [CriteriaValue1],
    [CriteriaValue2],
    [FromValue],
    [ToValue]
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] with (nolock)
WHERE
    [MappingSetID] = @MappingSetID
ORDER BY
    [MappingSetID]

/**
 * my mapping sets
 */
declare @CreatedBy nvarchar(128)=N'%kevin%'
SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [MappingSetID],
    [Description]
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets] with (nolock)
WHERE
    [CreatedBy] LIKE @CreatedBy
ORDER BY
    [MappingSetID]
