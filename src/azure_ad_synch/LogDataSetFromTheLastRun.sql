/*
 * Log data set from the last run
 */

-------------------------------------------------------------------------------

declare @lastRunStart int

-------------------------------------------------------------------------------

select top 1
    @lastRunStart = min(AutoID) - 1 -- the start message doesn't have the run id ><. doh!
from
    dbo.atbl_AzureAdSync_Log with (nolock)
where
    json_value(LogMessage, '$.runId') is not null
group by
    json_value(LogMessage, '$.runId')
order by
    min(AutoID) desc

-------------------------------------------------------------------------------

select
    AutoID 'id',
    json_query(LogMessage) 'logEntry'
from
    dbo.atbl_AzureAdSync_Log with (nolock)
where
    AutoID >= @lastRunStart
for
    json path

-------------------------------------------------------------------------------