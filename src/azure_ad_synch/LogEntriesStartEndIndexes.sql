/*
 * Run Ids and start-end indexes
 */
select -- top 1
    Count = count(*),
    RunID = json_value(LogMessage, '$.runId'),
    StartAutoID = min(AutoID) - 1, -- the start message doesn't have the run id ><. doh!
    EndAutoID = max(AutoID)
from
    dbo.atbl_AzureAdSync_Log with (nolock)
where
    json_value(LogMessage, '$.runId') is not null
group by
    json_value(LogMessage, '$.runId')
order by
    min(AutoID) desc
