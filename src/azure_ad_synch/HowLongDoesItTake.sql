
WITH JobEntries AS (
SELECT
	RunID = JSON_VALUE(LogMessage, '$.runId'),
	JobID = JSON_VALUE(LogMessage, '$.jobId'),
	Created
FROM
	[dbo].[atbl_AzureAdSync_log] WITH (NOLOCK)
WHERE
	JSON_VALUE(LogMessage, '$.jobId') is not null
)

--select * from JobEntries -- debug

/*
 *  Job Duration
 */
SELECT
	JobID,
	JobStart = MIN(Created),
	JobEnd = MAX(Created),
	JobDuration = DATEDIFF(millisecond, MIN(Created), MAX(Created))
FROM
	JobEntries
GROUP BY
	JobID
ORDER BY
	MIN(Created) DESC

/*
 *  Run Duration
 */
--SELECT
--	RunID,
--	RunStart = MIN(Created),
--	RunEnd = MAX(Created),
--	RunDuration = DATEDIFF(millisecond, MIN(Created), MAX(Created))
--FROM
--	JobEntries
--GROUP BY
--	RunID
--ORDER BY
--	MIN(Created) DESC
