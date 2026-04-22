
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

-------------------------------------------------------------------------------

declare @ServiceName nvarchar(128)=N'Integrations.Interface.RestAPI'

select
    Message,
    ExecutionGroupRef,
    ExecutionBatchRef
into
    #LastLogEntries
from
    dbo.atbl_Integrations_ScheduledTasksServicesLog AS L WITH(NOLOCK)
where
    [ServiceName] = @ServiceName
    and Created > dateadd(hour, - 24, getdate())

-- select count(*) from #LastLogEntries

-------------------------------------------------------------------------------
select
    DcsPipelineErrors.GroupRef,
    Pipeline = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups G with (nolock)
        where G.PrimKey = DcsPipelineErrors.GroupRef
    ),
    DcsPipelineErrors.BatchRef,
    RevsionsFiles.DCS_DocumentID,
    RevsionsFiles.DCS_Domain,
    RevsionsFiles.DCS_Revision,
    object_guid = json_value(DcsPipelineErrors.JsonContent, '$.object_guid'),
    md5hash = json_value(DcsPipelineErrors.JsonContent, '$.md5hash'),
    fileSize = json_value(DcsPipelineErrors.JsonContent, '$.fileSize'),
    originalFilename = json_value(DcsPipelineErrors.JsonContent, '$.originalFilename'),
    DcsPipelineErrors.Message,
    ImportStatus = RevsionsFiles.INTEGR_REC_STATUS

from
    (   
    select
        LastPipelineBatches.GroupRef,
        LastPipelineBatches.BatchRef,
        Message =
            case
                when LastLogEntries.Message like '%ExecuteProcedure - The wait operation timed out%' then 'ProcedureTimeOut'
                when LastLogEntries.Message like '%OutOfMemoryException%' then 'OutOfMemoryException'
                when LastLogEntries.Message like '%Request failed with status code NotFound%' then '404 - NotFound'
                when LastLogEntries.Message like '%Remote file stream returned no content%' then 'No stream content'
                else LastLogEntries.Message
            end,
        -- MessageContainsJson = isjson(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1)),
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
        (
            select
                GroupRef = @IvarAasen,
                BatchRef = (
                    select top 1 INTEGR_REC_BATCHREF
                    from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
                    where INTEGR_REC_GROUPREF = @IvarAasen
                )
            union all
            select
                GroupRef = @Munin,
                BatchRef = (
                    select top 1 INTEGR_REC_BATCHREF
                    from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
                    where INTEGR_REC_GROUPREF = @Munin
                )
            union all
            select
                GroupRef = @Valhall,
                BatchRef = (
                    select top 1 INTEGR_REC_BATCHREF
                    from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
                    where INTEGR_REC_GROUPREF = @Valhall
                )
            union all
            select
                GroupRef = @Yggdrasil,
                BatchRef = (
                    select top 1 INTEGR_REC_BATCHREF
                    from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
                    where INTEGR_REC_GROUPREF = @Yggdrasil
                )
            union all
            select
                GroupRef = @EdvardGrieg,
                BatchRef = (
                    select top 1 INTEGR_REC_BATCHREF
                    from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
                    where INTEGR_REC_GROUPREF = @EdvardGrieg
                )
        ) LastPipelineBatches
        join #LastLogEntries LastLogEntries
            on LastLogEntries.ExecutionBatchRef = LastPipelineBatches.BatchRef
            and LastLogEntries.ExecutionGroupRef = LastPipelineBatches.GroupRef
    ) DcsPipelineErrors
    join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RevsionsFiles with (nolock)
        on RevsionsFiles.object_guid = json_value(JsonContent, '$.object_guid')
        and RevsionsFiles.md5hash = json_value(JsonContent, '$.md5hash')
order by
    Pipeline,
    DCS_Domain,
    DCS_DocumentID,
    DCS_Revision