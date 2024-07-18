/*
 * Pipeline run times
 *
 * OBS: Failed runs and partial ("sandboxed") runs will distort the running times
 */
DECLARE @PipelineName NVARCHAR(256) = 'DTS%Documents' -- '%' -- 'DTS (Comos/EIS: YGGDRASIL) - Tags'
DECLARE @ExcludeUnfinishedTasksAndIncompletePipelines BIT = 1
SELECT
    Pipeline = V.GroupName,
    MinRunTime = CONVERT(NVARCHAR, DATEADD(S, MIN(V.DurationInSeconds), 0), 108),
    AvgRunTime = CONVERT(NVARCHAR, DATEADD(S, AVG(V.DurationInSeconds), 0), 108),
    MaxRunTime = CONVERT(NVARCHAR, DATEADD(S, MAX(V.DurationInSeconds), 0), 108)
FROM
(
    SELECT
        T.[GroupName],
        T.[GroupRef],
        T.[ExecutionBatchRef],
        ExecutionStart = MIN(T.[ExecutionStart]),
        ExecutionEnd = MAX(T.[ExecutionEnd]),
        AllStatus = STRING_AGG(T.[Status], ','),
        NumberOfSteps = COUNT(T.[TaskRef]),
        DurationInSeconds = DATEDIFF(S, MIN(T.[ExecutionStart]), ISNULL(MAX(T.[ExecutionEnd]), GETUTCDATE()))
    FROM
        dbo.atbl_Integrations_ScheduledTasksExecutionLog AS T WITH (NOLOCK)
    WHERE
        T.[GroupName] like @PipelineName
        AND (
            T.[Status] = 'Finished' -- only count successfully completed tasks
            OR @ExcludeUnFinishedTasksAndIncompletePipelines = 0
        )
    GROUP BY
        T.[GroupName],
        T.[GroupRef],
        T.[ExecutionBatchRef]
    HAVING
        (
            COUNT(T.[TaskRef]) = (
                SELECT COUNT(DISTINCT U.[TaskRef])
                FROM dbo.atbl_Integrations_ScheduledTasksExecutionLog AS U WITH (NOLOCK)
                WHERE U.[GroupRef] = T.[GroupRef]
            )
            OR @ExcludeUnFinishedTasksAndIncompletePipelines = 0
        )
) V
GROUP BY
    V.[GroupName],
    V.[GroupRef]
ORDER BY
    V.[GroupName]

/*
 * All status values
 */
-- SELECT DISTINCT T.[Status]
-- FROM dbo.atbl_Integrations_ScheduledTasksExecutionLog AS T WITH (NOLOCK)
-- ORDER BY T.[Status]

/*
 * Pipeline number of steps
 */
-- SELECT
--     T.[GroupName],
--     NumberOfSteps = COUNT(DISTINCT T.[TaskRef])
-- FROM
--     dbo.atbl_Integrations_ScheduledTasksExecutionLog AS T WITH (NOLOCK)
-- GROUP BY
--     T.[GroupName]
-- ORDER BY
--     T.[GroupName]

/*
 * Pipeline run counts
 */
-- SELECT
--     Pipeline = T.[GroupName],
--     RunCount = COUNT(DISTINCT T.[ExecutionBatchRef])
-- FROM
--     dbo.atbl_Integrations_ScheduledTasksExecutionLog AS T WITH (NOLOCK)
-- GROUP BY
--     T.[GroupName]
-- ORDER BY
--     T.[GroupName]
    
/*
 * Pipeline names
 */
-- SELECT DISTINCT Pipeline = T.[GroupName]
-- FROM dbo.atbl_Integrations_ScheduledTasksExecutionLog AS T WITH (NOLOCK)
-- ORDER BY T.[GroupName]