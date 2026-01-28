
/*
 * Data load time
 */
select
    RunId
    , JobId
    , GroupPrimKey
    , AzureID
    , GroupName
into
    #RunsJobsGroups
from
    (
        select
            RunId = json_value(LogMessage, '$.runId'),
            JobId = json_value(LogMessage, '$.jobId'),
            GroupPrimKey = json_value(LogMessage, '$.meta.rowData[4]')
        from
            dbo.atbl_AzureAdSync_Log with (nolock)
        where
            json_value(LogMessage, '$.runId') is not null
            and json_value(LogMessage, '$.message.title') = 'AzureAdGroupUserLookup Started'
        group by
            json_value(LogMessage, '$.runId')
            , json_value(LogMessage, '$.jobId')
            , json_value(LogMessage, '$.meta.rowData[4]')
    ) T
    left join dbo.atbl_AzureAdSync_Groups G with (nolock)
        on G.PrimKey = T.GroupPrimKey

-- select * from #RunsJobsGroups

select
    U.RunId,
    U.JobId,
    RJG.AzureID,
    RJG.GroupName,
    U.JobMessageCount,
    U.ImportedRecordCount,
    U.JobStart,
    U.JobEnd,
    U.JobDuration
from
    (
        select
            RunId,
            JobId,
            JobMessageCount = count(*),
            ImportedRecordCount = sum(ResponseRecords),
            JobStart = min(Created),
            JobEnd = max(Created),
            JobDuration = DATEDIFF(second, MIN(Created), MAX(Created))
        from (
            select
                RunId = json_value(LogMessage, '$.runId'),
                JobId = json_value(LogMessage, '$.jobId'),
                ResponseRecords = (select count(*) from openjson(LogMessage, '$.response.value')),
                Created
            from
                dbo.atbl_AzureAdSync_Log with (nolock)
            where
                json_value(LogMessage, '$.runId') is not null
                and json_query(LogMessage, '$.response') is not null
        ) T
        group by
            RunId,
            JobId
    ) U
    left join #RunsJobsGroups RJG
        on U.RunId = RJG.RunId
        and U.JobId = RJG.JobId
order by
    JobEnd desc

/*
 * Responses per run
 */
-- select
--     RunID = json_value(LogMessage, '$.runId'),
--     ResponsesPerRun = count(*)
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- where json_query(LogMessage, '$.response') is not null
-- group by
--     json_value(LogMessage, '$.runId')

/*
 * Sample Group Refs
 */
-- select top 50
--     OdataNextLink = json_value(LogMessage, '$.response."@odata.nextLink"'),
--     substring(json_value(LogMessage, '$.response."@odata.nextLink"'), len('/groups/') + charindex('/groups/', json_value(LogMessage, '$.response."@odata.nextLink"')), 36)
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- where
--     json_query(LogMessage, '$.response') is not null
--     and json_query(LogMessage, '$.response.value') is not null
-- order by newid()

/*
 * Sample responses without "value" array
 */
-- select top 50 LogMessage
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- where
--     json_query(LogMessage, '$.response') is not null
--     and json_query(LogMessage, '$.response.value') is null
-- order by newid()

/*
 * Sample of entries tagged with run id
 */
-- select top 50 LogMessage
-- from dbo.atbl_AzureAdSync_Log with (nolock)
-- where json_value(LogMessage, '$.runId') is not null
-- order by newid()