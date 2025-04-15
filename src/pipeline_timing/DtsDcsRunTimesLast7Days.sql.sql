/*
 * DTS - DCS run times last 7 days
 */
DECLARE @Param0 int = -7
SELECT
    ExecutionBatchRef,
    Pipeline = (SELECT Name FROM dbo.atbl_Integrations_ScheduledTasksConfigGroups AS S WITH (NOLOCK) where PrimKey = [GroupRef]),
    [Initiated] = MIN([Initiated]),
    StartTime = MIN(ExecutionStart),
    EndTime = MAX(ExecutionEnd),
    DurationInSeconds = DATEDIFF(
        S,
        MIN(ExecutionStart),
        MAX(ExecutionEnd)
    ),
    Duration = CONVERT(
        NVARCHAR,
        DATEADD(
            S,
            DATEDIFF(
                S,
                MIN(ExecutionStart),
                MAX(ExecutionEnd)
            ),
            0
        ),
        108
    ),
    Fail = CAST((
        CASE
            WHEN EXISTS (
                SELECT *
                FROM [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor] STAM
                WHERE
                    STAM.ExecutionBatchRef = Runs.ExecutionBatchRef
                    AND [ErrorMsg] IS NOT NULL
            )
            THEN 1
            ELSE 0
        END
    ) AS BIT)

FROM
    [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor] Runs
WHERE
    (
        [Initiated] >= DATEADD(DAY, @Param0, GETUTCDATE())
        AND [GroupRef] in (
            'edadd424-81ce-4170-b419-12642f80cfde',
            'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
            '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
            'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
            'f6c3687c-5511-48f2-98e5-8e84eee9b689'
        )
    )
GROUP BY
    [ExecutionBatchRef],
    [GroupRef]
ORDER BY
    Pipeline,
    [Initiated] DESC
/*
 * DTS - DCS Pipeline run counts last 7 days
 */
-- DECLARE @Param0 int = -7
-- SELECT
--     Pipeline = (SELECT Name FROM dbo.atbl_Integrations_ScheduledTasksConfigGroups AS S WITH (NOLOCK) where PrimKey = [GroupRef]),
--     RunCount = COUNT(distinct ExecutionBatchRef)
-- FROM
--     [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor]
-- WHERE
--     (
--         [Initiated] >= DATEADD(DAY, @Param0, GETUTCDATE())
--         AND [GroupRef] in (
--             'edadd424-81ce-4170-b419-12642f80cfde',
--             'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
--             '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
--             'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
--             'f6c3687c-5511-48f2-98e5-8e84eee9b689'
--         )
--     )
-- GROUP BY
--     [GroupRef]

/*
 * base from integrations-scheduledtasks-activitymonitor (Yggdrasil)
 */
-- DECLARE @Param0 int = -7,
-- @Param1 nvarchar(36) = N'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
-- SELECT DISTINCT
--     [ScheduleRef],
--     [ExecutionBatchRef],
--     [GroupRef],
--     [TaskRef],
--     [Name],
--     [TaskName],
--     [Status],
--     [Initiated],
--     [ExecutionStart],
--     [ExecutionEnd],
--     [Duration],
--     [SortOrder],
--     [ErrorMsg]
-- FROM
--     [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor]
-- WHERE
--     (
--         [Initiated] >= DATEADD(DAY, @Param0, GETUTCDATE())
--         AND [GroupRef] = @Param1
--     )
-- ORDER BY
--     [Initiated] DESC,
--     [GroupRef],
--     [SortOrder]
