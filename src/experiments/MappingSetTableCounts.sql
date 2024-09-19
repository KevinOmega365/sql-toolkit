/*
 * get the table counts per mapping
 */
select
    MappingSetID,
    TargetTableCount = count(distinct TargetTable)
from
    (
        
        SELECT 
            S.GroupRef
            , G.Name
            , S.TargetTable
            , FMS.MappingSetID
            , FMS.Description
            , V.MappingSetValueID
            , S.CriteriaField1
            , V.CriteriaValue1
            , S.CriteriaField2
            , V.CriteriaValue2
            , S.FromField
            , V.FromValue
            , S.ToField
            , V.ToValue
            , S.Required
            , FMS.PriorityOrder
            , V.MappingType
            , FMS.CreatedBy
        FROM dbo.atbv_Integrations_Configurations_FieldMappingSets_Subscribers AS S WITH (NOLOCK) 
        INNER JOIN dbo.atbl_Integrations_Configurations_FieldMappingSets AS FMS WITH (NOLOCK) 
            ON FMS.MappingSetID = S.MappingSetID
        INNER JOIN dbo.atbl_Integrations_Configurations_FieldMappingSets_Values AS V WITH (NOLOCK)
            ON V.MappingSetID = FMS.MappingSetID
        INNER JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups AS G WITH (NOLOCK)
            ON G.PrimKey = S.GroupRef

    ) T
-- where
--     CreatedBy = 'a_kevin'
group by
    MappingSetID
order by
    TargetTableCount desc