/*
 * Assembly log file error details
 */

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

select
    STCG.Name,
    STSL.ShortMessage,
    RF.DCS_Domain,
    RF.DCS_DocumentID,
    RF.DCS_Revision,
    RF.DCS_OriginalFileName,
    RF.object_guid,
    RF.DCS_FileRef

    -- , *

from
    (
        select
            ExecutionGroupRef,
            ExecutionBatchRef,
            Created,
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
            ),
            Message,
            ShortMessage =
                case
                    when Message like '%Request failed with status code NotFound%' then 'Request failed with status code NotFound'
                    when Message like '%Remote file stream returned no content%' then 'Remote file stream returned no content'
                    else Message
                end
        from
            dbo.atbl_Integrations_ScheduledTasksServicesLog  with (nolock)
        where
            Created > cast(getdate() as date)
            and ExecutionGroupRef in (
                @IvarAasen,
                @Munin,
                @Valhall,
                @Yggdrasil,
                @EdvardGrieg
            )
    )
    STSL
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
        on STCG.PrimKey = STSL.ExecutionGroupRef
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
        on RF.INTEGR_REC_BATCHREF = STSL.ExecutionBatchRef
        and RF.object_guid = json_value(JsonContent, '$.object_guid')
order by
    STSL.Created desc
