select
    DCS_Domain,
    DCS_DocumentID,
    DCS_Revision,
    INTEGR_REC_ERROR,
    Message = case when Message like '%Download response status code was 404: NotFound%' then 'Download response status code was 404: NotFound' else Message end,
    AssemblyLogEntries.Created
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles RevisionsFiles with (nolock)
    join (
        select
            Message,
            json = substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1),
            object_guid = json_value(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1), '$.object_guid'),
            ExecutionBatchRef,
            Created
        from
            dbo.atbl_Integrations_ScheduledTasksServicesLog with (nolock)
        where
            CHARINDEX('{', Message) > 0
            and CHARINDEX('}', Message)> 0
            and isjson(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1)) = 1
            -- and ExecutionBatchRef in (
            --     select INTEGR_REC_BATCHREF
            --     from dbo.ltbl_Import_DTS_DCS_RevisionsFiles RevisionsFiles with (nolock)
            -- )
    ) AssemblyLogEntries
        on RevisionsFiles.object_guid = AssemblyLogEntries.object_guid
        and RevisionsFiles.INTEGR_REC_BATCHREF = AssemblyLogEntries.ExecutionBatchRef

order by
    DCS_Domain,
    DCS_DocumentID,
    DCS_Revision,
    AssemblyLogEntries.Created
