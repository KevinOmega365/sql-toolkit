declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'
declare
    @GroupRef uniqueidentifier = @Yggdrasil

SELECT
    Count = count(*),
    MappingSetID,
    TargetTable,
    FromField,
    ToField
FROM
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings
WHERE
    GroupRef = @GroupRef
group by
    MappingSetID,
    TargetTable,
    FromField,
    ToField
order by
    TargetTable,
    FromField,
    ToField

/*
 * web grid view
 */
-- SELECT
--     GroupRef,
--     Name,
--     TargetTable,
--     MappingSetID,
--     Description,
--     MappingSetValueID,
--     CriteriaField1,
--     CriteriaValue1,
--     CriteriaField2,
--     CriteriaValue2,
--     FromField,
--     FromValue,
--     ToField,
--     ToValue,
--     Required,
--     PriorityOrder,
--     MappingType
-- FROM
--     dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings
-- WHERE
--     GroupRef = @GroupRef
-- ORDER BY
--     GroupRef,
--     TargetTable,
--     PriorityOrder,
--     MappingSetID,
--     MappingSetValueID