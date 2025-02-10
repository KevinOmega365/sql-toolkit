
select
    Created,
    RunningTime = coalesce(json_value(LogMessage, '$.FetchTime'), json_value(LogMessage, '$.ProcedureTime')),
    ActionType = json_value(LogMessage, '$.Action'),
    ProcedureName = json_value(LogMessage, '$.Procedure'),
    ApiQuery =
        case when json_value(LogMessage, '$.Config') is not null
            then
                case when json_value(LogMessage, '$.Config') like '%ReportScheduleByIdWithRevisions%' 
                    then 'Activities'
                    else 'ProjectReports'
                end
            else
                null
        end,
    ReportID = json_value(json_value(LogMessage, '$.Config'), '$.jsonBody.variables.id'),

    HasError = case when json_query(LogMessage, '$.error') is not null then 'error' else '' end,
    LogMessage
from
    dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock)
order by
    Created desc

/*
 * Errors
 */
-- select
--     Created,
--     Action = json_value(LogMessage, '$.Action'),
--     LogMessage
-- from
--     dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock)
-- where
--     json_query(LogMessage, '$.error') is not null
-- order by
--     Created desc

/*
 * Log Dump
 */
-- select * from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock) order by Created desc
