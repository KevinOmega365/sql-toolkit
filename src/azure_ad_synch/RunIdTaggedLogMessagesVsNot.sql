/*
 * Sample of entries NOT tagged with run id
 */
-- select top 50 LogMessage
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- where json_value(LogMessage, '$.runId') is null
-- order by newid()

/*
 * Log entries tagged with run id
 */
select
    TotalLogMessages = count(*),
    RunIdTaggedEntryCount = sum(WithRunId),
    UnTaggedCount = sum(NoRunId),
    TaggedRatio = format(1.0 * sum(WithRunId) / count(*), 'P')
from (
    select
        WithRunId = case when json_value(LogMessage, '$.runId') is not null then 1 else 0 end,
        NoRunId = case when json_value(LogMessage, '$.runId') is null then 1 else 0 end
    from
        dbo.atbl_AzureAdSync_Log with (nolock)
) T

/*
 * Sample
 */
-- select top 50 *
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- order by newid()
