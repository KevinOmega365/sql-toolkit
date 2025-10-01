
SELECT
    CreatedBy,
    Count(*)
FROM
    dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipelines WITH (NOLOCK)
WHERE
    Inactive = 0
GROUP BY
    CreatedBy
ORDER BY
    CreatedBy

SELECT
    CreatedBy,
    Name
FROM
    dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipelines WITH (NOLOCK)
WHERE
    Inactive = 0
ORDER BY
    CreatedBy, Name


SELECT
    Tasks.CreatedBy,
    Count(*)
FROM
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Tasks WITH (NOLOCK)
    JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipelines WITH (NOLOCK)
        ON Pipelines.PrimKey = Tasks.GroupRef
WHERE
    Pipelines.Inactive = 0
    and Tasks.Inactive = 0
GROUP BY
    Tasks.CreatedBy
ORDER BY
    Tasks.CreatedBy

SELECT
    Tasks.CreatedBy,
    Tasks.Name,
    Pipelines.Name
FROM
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Tasks WITH (NOLOCK)
    JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipelines WITH (NOLOCK)
        ON Pipelines.PrimKey = Tasks.GroupRef
WHERE
    Pipelines.Inactive = 0
    and Tasks.Inactive = 0
ORDER BY
    Tasks.CreatedBy,
    Tasks.Name
