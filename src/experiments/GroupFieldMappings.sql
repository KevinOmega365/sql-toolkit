declare @GroupRef nvarchar(36) = N'fb36536c-db59-4926-952a-5868262a44a5'

-------------------------------------------------------------------------------

SELECT DISTINCT
    [CriteriaField1],
    [CriteriaField2],
    [FromField],
    [ToField]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
WHERE
    [GroupRef] = @GroupRef

-------------------------------------------------------------------------------

SELECT DISTINCT
    [CriteriaValue1],
    [CriteriaValue2],
    [FromValue],
    [ToValue],
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
WHERE
    [GroupRef] = @GroupRef

-------------------------------------------------------------------------------

SELECT DISTINCT
    [MappingSetValueID]
FROM
    [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
WHERE
    [GroupRef] = @GroupRef

-------------------------------------------------------------------------------

-- SELECT
--     [GroupRef],
--     [Name],
--     [TargetTable],
--     [MappingSetID],
--     [Description],
--     [MappingSetValueID],
--     [CriteriaField1],
--     [CriteriaValue1],
--     [CriteriaField2],
--     [CriteriaValue2],
--     [FromField],
--     [FromValue],
--     [ToField],
--     [ToValue],
--     [Required],
--     [PriorityOrder],
--     [MappingType]
-- FROM
--     [dbo].[aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings]
-- WHERE
--     [GroupRef] = @GroupRef
