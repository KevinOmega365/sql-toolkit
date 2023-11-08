
/**
 * Queue processor errors
 */
SELECT
    [Created],
    [TypeName],
    [MethodName],
    [Args],
    [ErrorMessage],
    [ErrorStackTrace],
    [ErrorTypeName],
    [PrimKey]
FROM
    [dbo].[stbv_System_QueueErrors]
WHERE
    [TableName] = 'atbl_AzureAdSync_Queue'
ORDER BY
    [Created] DESC

/**
 * Scheduler job details
 */
SELECT
    [PrimKey],
    [CreatedBy],
    [Updated],
    [ProcedureName],
    [Description],
    [Frequency],
    [LastRun],
    [Owner],
    [LastErrorMessage],
    [Duration],
    [StartDate],
    [Monday],
    [Tuesday],
    [Wednesday],
    [Thursday],
    [Friday],
    [Saturday],
    [Sunday],
    [Type],
    [Timeout],
    [Job_ID],
    [Paused],
    [PausedBy],
    [UseTransaction],
    [QueueProcessor_ID],
    [QueueProcessorWithName],
    [IsLocal],
    [CronSchedule]
FROM
    [dbo].[sviw_System_Jobs]
WHERE
    [ProcedureName] LIKE '%azuread%'
ORDER BY
    [Job_ID] DESC
