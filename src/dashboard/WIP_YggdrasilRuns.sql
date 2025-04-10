DECLARE @Param0 int = -7,
@Param1 nvarchar(36) = N'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
SELECT DISTINCT
    [ScheduleRef],
    [ExecutionBatchRef],
    [GroupRef],
    [TaskRef],
    [Name],
    [TaskName],
    [Status],
    [Initiated],
    [ExecutionStart],
    [ExecutionEnd],
    [Duration],
    [SortOrder],
    [ErrorMsg]
FROM
    [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor]
WHERE
    (
        [Initiated] >= DATEADD(DAY, @Param0, GETUTCDATE())
        AND [GroupRef] = @Param1
    )
ORDER BY
    [Initiated] DESC,
    [GroupRef],
    [SortOrder]