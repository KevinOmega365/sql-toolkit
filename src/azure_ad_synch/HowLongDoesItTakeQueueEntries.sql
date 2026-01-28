DECLARE @JobID UNIQUEIDENTIFIER = NULL -- '82c24a74-603e-4abe-9306-cfc4183d3045'

; WITH JobsQueueEntries AS (
    SELECT
        JobQueueEntry = 
            ROW_NUMBER()
            Over(
                PARTITION BY
                    JSON_VALUE(LogMessage, '$.jobId'),
                    JSON_VALUE(LogMessage, '$.message.type')
                ORDER BY AutoID
            ),
        JobID = JSON_VALUE(LogMessage, '$.jobId'),
        Created,
        MessageType = JSON_VALUE(LogMessage, '$.message.type')
    FROM
        [dbo].[atbl_AzureAdSync_log] WITH (NOLOCK)
    WHERE
        JSON_VALUE(LogMessage, '$.message.type') IN ('START', 'END')
)

--select * from JobsQueueEntries -- debug

SELECT
    JobID,
    JobQueueEntry,
    JobStart = MIN(Created),
    JobEnd = MAX(Created),
    JobDuration = DATEDIFF(millisecond, MIN(Created), MAX(Created))
FROM
    JobsQueueEntries
WHERE
    JobID = @JobID
    OR @JobID IS NULL
GROUP BY
    JobID,
    JobQueueEntry
ORDER BY
    MIN(Created) DESC
