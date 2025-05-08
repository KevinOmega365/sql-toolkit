declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @QuestionDocuments table (
    DocumentID nvarchar(max),
    Revision nvarchar(max)
)
insert into @QuestionDocuments
values
    ('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION') --, ...

select distinct
    T.ImportDomain,
    T.DocumentID,
    T.Revision,
    T.ImportDocumentExists,
    T.ImportRevisionExists,
    T.PimsDocumentExists,
    T.PimsRevisionExists,
    FileMetadataExists = U.FileMetadata,
    FileDownloadExists = U.FileDownload,
    FileStorageExists = U.FileStorage,
    V.originalFilename,
    V.object_guid,
    V.Message
from
(
    select
        ImportDomain = ID.DCS_Domain,   
        Q.DocumentID,
        Q.Revision,
        ImportDocumentExists = case when ID.PrimKey is null then 0 else 1 end,
        ImportRevisionExists = case when IR.PrimKey is null then 0 else 1 end,
        PimsDocumentExists = case when PD.PrimKey is null then 0 else 1 end,
        PimsRevisionExists = case when PR.PrimKey is null then 0 else 1 end
    from
        @QuestionDocuments Q -- hang everything off Q
        left join dbo.ltbl_Import_DTS_DCS_Documents as ID with (nolock)
            on ID.DCS_DocumentID = Q.DocumentID
        left join dbo.ltbl_Import_DTS_DCS_Revisions as IR with (nolock)
            on IR.DCS_DocumentID = Q.DocumentID
            and IR.DCS_Revision = Q.Revision
        left join dbo.atbl_DCS_Documents as PD with (nolock)
            on PD.DocumentID = Q.DocumentID
        left join dbo.atbl_DCS_Revisions as PR with (nolock)
            on PR.DocumentID = Q.DocumentID
            and PR.Revision = Q.Revision
) T
left join (
    select
        R.DCS_Domain,
        R.DCS_DocumentID,
        R.DCS_Revision,
        DocIsInPims = case when D.PrimKey is null then 0 else 1 end,
        FileMetadata = case when RF.PrimKey is null then 0 else 1 end,
        FileDownload = case when F.PrimKey is null then 0 else 1 end,
        FileStorage = case when SF.PrimKey is null then 0 else 1 end
    from
        dbo.ltbl_Import_DTS_DCS_Revisions R with (nolock)

        left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
            on RF.DCS_Domain = R.DCS_Domain
            and RF.DCS_DocumentID = R.DCS_DocumentID
            and RF.DCS_Revision = R.DCS_Revision
        left join dbo.ltbl_Import_DTS_DCS_Files as F with (nolock)
            on F.object_guid = RF.object_guid
        left join dbo.stbl_System_Files as SF with (nolock)
            on SF.PrimKey = F.FileRef

        left join dbo.atbl_DCS_Documents D with (nolock)
            on D.Domain = R.DCS_Domain
            and D.DocumentID = R.DCS_DocumentID
) U
    on U.DCS_Domain = T.ImportDomain
    and U.DCS_DocumentID = T.DocumentID
    and U.DCS_Revision = T.Revision
left join (
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
) V
    on V.DCS_DocumentID = T.DocuMentID
    and V.DCS_Revision = T.Revision
where
    ImportDocumentExists = 0
    or ImportRevisionExists = 0
    or PimsDocumentExists = 0
    or PimsRevisionExists = 0
order by
    T.ImportDomain,
    T.DocumentID,
    T.Revision
