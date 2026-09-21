DECLARE @PipelineSearchFilter NVARCHAR(128) = N'%onb%'
SELECT
    ProcedureName,
    Count,
    Pipelines
FROM
    (
        SELECT
            ProcedureName = JSON_VALUE(T.StepConfig, '$.Procedure'),
            Count = COUNT(*),
            Pipelines = STRING_AGG(G.Name, ', ')
        FROM
            dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS T WITH (NOLOCK)
            JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups AS G WITH (NOLOCK)
                ON G.PrimKey = T.GroupRef
        WHERE
            G.SearchColumn LIKE @PipelineSearchFilter
            AND T.StepType = 'Stored Procedure'
        GROUP BY
            JSON_VALUE(T.StepConfig, '$.Procedure')
    ) AS T
WHERE
    OBJECT_DEFINITION(OBJECT_ID(ProcedureName)) LIKE '%trim%'
ORDER BY
    ProcedureName