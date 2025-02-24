declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

/*
 * Correlated file errors
 */
select
    LogEntries.Created,
    LogEntries.Name,
    RF.DCS_DocumentID,
    RF.DCS_Revision,
    LogEntriesFileDetails.originalFilename,
    LogEntriesFileDetails.object_guid,
    LogEntries.Message,
    RF.INTEGR_REC_ERROR
from
    (
        select
            STSL.Created,
            STCG.Name,
            Task = STCGT.SequenceOrder + ' - ' + STCGT.Name,
            Message =
                case
                    when STSL.Message like '%ExecuteProcedure - The wait operation timed out%' then 'ProcedureTimeOut'
                    when STSL.Message like '%OutOfMemoryException%' then 'OutOfMemoryException'
                    when STSL.Message like '%Request failed with status code NotFound%' then '404 - NotFound'
                    else STSL.Message
                end,
            MessageContainsJson = isjson(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1)),
            JsonContent = reverse(
                            left(
                                reverse(
                                    left(
                                        Message,
                                        charindex('}', Message)
                                    )
                                ),
                                charindex(
                                    '{',
                                    reverse(left(Message, charindex('}', Message)))
                                )
                            )
                        )
        from
            dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
            join dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
                on STCG.PrimKey = STSL.ExecutionGroupRef
            join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks STCGT with (nolock)
                on STCGT.PrimKey = STSL.ExecutionTaskRef
        where
            STSL.Created > dateadd(hour, -24, getdate())
            and STCG.PrimKey in (
                @IvarAasen,
                @Munin,
                @Valhall,
                @Yggdrasil,
                @EdvardGrieg
        )
        and isjson(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1)) = 1 -- actually has json
    ) LogEntries
    cross apply openjson(JsonContent) with (
        originalFilename nvarchar(max),
        object_guid nvarchar(max),
        md5hash nvarchar(max)
    ) LogEntriesFileDetails
    join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
        on RF.object_guid = LogEntriesFileDetails.object_guid

order by
    Created desc


/*
 * Error Overview
 */
-- select top 50
--     STSL.Created,
--     STCG.Name,
--     Task = STCGT.SequenceOrder + ' - ' + STCGT.Name,
--     Message =
--         case
--             when STSL.Message like '%ExecuteProcedure - The wait operation timed out%' then 'ProcedureTimeOut'
--             when STSL.Message like '%OutOfMemoryException%' then 'OutOfMemoryException'
--             when STSL.Message like '%Request failed with status code NotFound%' then 'NotFound'
--             else STSL.Message
--         end
-- from
--     dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
--     join dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
--         on STCG.PrimKey = STSL.ExecutionGroupRef
--     join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks STCGT with (nolock)
--         on STCGT.PrimKey = STSL.ExecutionTaskRef
-- where
--     STSL.Created > dateadd(hour, -24, getdate())
--     and STCG.PrimKey in (
--         @IvarAasen,
--         @Munin,
--         @Valhall,
--         @Yggdrasil,
--         @EdvardGrieg
--     )
-- order by
--     STSL.Created desc

/*
 * Error log last 50 or last 24 hour for DTS - DCS
 */
-- select top 50
--     STCG.Name,
--     Task = STCGT.SequenceOrder + ' - ' + STCGT.Name,
--     STSL.CallingMethod,
--     STSL.CallingObject,
--     -- STSL.CallingParameters,
--     -- STSL.CDL,
--     STSL.Created,
--     -- STSL.CreatedBy,
--     -- STSL.CUT,
--     -- STSL.ExecutionBatchRef,
--     -- STSL.ExecutionGroupRef,
--     -- STSL.ExecutionTaskRef,
--     STSL.LogLevel,
--     STSL.Message,
--     -- STSL.PrimKey,
--     -- STSL.ServiceName,
--     STSL.StackTrace
-- from
--     dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
--     join dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
--         on STCG.PrimKey = STSL.ExecutionGroupRef
--     join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks STCGT with (nolock)
--         on STCGT.PrimKey = STSL.ExecutionTaskRef
-- where
--     STSL.Created > dateadd(hour, -24, getdate())
--     and STCG.PrimKey in (
--         @IvarAasen,
--         @Munin,
--         @Valhall,
--         @Yggdrasil,
--         @EdvardGrieg
--     )
-- order by
--     STSL.Created desc
