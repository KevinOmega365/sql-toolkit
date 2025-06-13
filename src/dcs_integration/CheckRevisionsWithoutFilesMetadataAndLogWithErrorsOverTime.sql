
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

/*
 * Latest Batches
 */
declare @LatestBatches table (
    INTEGR_REC_GROUPREF uniqueidentifier,
    INTEGR_REC_BATCHREF uniqueidentifier
)
insert into @LatestBatches
select
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF
from
(
    select
        INTEGR_REC_GROUPREF,
        INTEGR_REC_BATCHREF,
        BatchAge = row_number() over (partition by INTEGR_REC_GROUPREF order by BatchCreated desc)
    from
        (
            select
                INTEGR_REC_GROUPREF,
                INTEGR_REC_BATCHREF,
                BatchCreated = max(Created)
            from
                dbo.ltbl_Import_DTS_DCS_Documents with (nolock)  -- look at the latest import; the newest error instance may be in the past
            group by
                INTEGR_REC_GROUPREF,
                INTEGR_REC_BATCHREF
        ) T
) U
where
    BatchAge = 1
order by
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF

-- select * from @LatestBatches -- debug

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @ErrorsOverTime table (
    GroupRef uniqueidentifier,
    BatchRef uniqueidentifier,
    Domain nvarchar(128),
    DocumentID nvarchar(128),
    Revision nvarchar(8),
    ErrorDurationBatches int,
    ObjectDurationDays int,
    ObjectFirstSeen datetime2,
    ObjectLastSeen datetime2
)
insert into @ErrorsOverTime
select
    GroupRef = EI.INTEGR_REC_GROUPREF,
    BatchRef = EI.INTEGR_REC_BATCHREF,
    Domain = json_value(ObjectKeys, '$[0]'),
    DocumentID = json_value(ObjectKeys, '$[1]'),
    Revision = json_value(ObjectKeys, '$[2]'),
    ErrorDurationBatches = (
        select count(distinct INTEGR_REC_BATCHREF)
        from dbo.ltbl_Import_DTS_DCS_ErrorsInstances Intances with (nolock)
        where Intances.ErrorRef = EI.ErrorRef
    ),
    ObjectDurationDays = datediff(day, EO.Created, EO.Updated),
    ObjectFirstSeen = EO.Created,
    ObjectLastSeen = EO.Updated
from
    @LatestBatches LatestBatches
    join dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
        on LatestBatches.INTEGR_REC_GROUPREF = EI.INTEGR_REC_GROUPREF
        and LatestBatches.INTEGR_REC_BATCHREF = EI.INTEGR_REC_BATCHREF
    join dbo.ltbl_Import_DTS_DCS_ErrorsObjects EO with (nolock)
        on EO.PrimKey = EI.ObjectRef
    join dbo.ltbl_Import_DTS_DCS_ErrorsDetails ED with (nolock)
        on ED.PrimKey = EI.ErrorRef

-- select * from @ErrorsOverTime -- debug

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @LogEntries table (
    GroupRef uniqueidentifier,
    BatchRef uniqueidentifier,
    object_guid uniqueidentifier,
    originalFilename nvarchar(256),
    Message nvarchar(max),
    Created datetime2
)
insert into @LogEntries
select
    ExecutionGroupRef,
    ExecutionBatchRef,
    LogEntriesFileDetails.object_guid,
    LogEntriesFileDetails.originalFilename,
    LogEntries.Message,
    LogEntries.Created
from
    (
        select
            STSL.ExecutionGroupRef,
            STSL.ExecutionBatchRef,
            STSL.Created,
            Message =
                case
                    when STSL.Message like '%ExecuteProcedure - The wait operation timed out%' then 'ProcedureTimeOut'
                    when STSL.Message like '%OutOfMemoryException%' then 'OutOfMemoryException'
                    when STSL.Message like '%Request failed with status code NotFound%' then '404 - NotFound'
                    else STSL.Message
                end,
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
            @LatestBatches LatestBatches
            join dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
                on LatestBatches.INTEGR_REC_GROUPREF = STSL.ExecutionGroupRef
                and LatestBatches.INTEGR_REC_BATCHREF = STSL.ExecutionBatchRef
        where
            isjson(substring(Message, CHARINDEX('{', Message), CHARINDEX('}', Message) - CHARINDEX('{', Message) + 1)) = 1 -- actually has json
    ) LogEntries
    cross apply openjson(JsonContent) with (
        originalFilename nvarchar(max),
        object_guid nvarchar(max),
        md5hash nvarchar(max)
    ) LogEntriesFileDetails

-- select * from @LogEntries -- debug

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @ImportExistence table (
    GroupRef uniqueidentifier,
    BatchRef uniqueidentifier,
    Domain nvarchar(128),
    DocumentID nvarchar(128),
    Revision nvarchar(8),
    ImportDocumentExists bit,
    ImportRevisionExists bit,
    ImportFileMetadata bit,
    ImportFileDownload bit,
    ImportFileStorage bit,
    PimsDocumentExists bit,
    PimsRevisionExists bit
)
insert into @ImportExistence
select
    Q.GroupRef,
    Q.BatchRef,
    Q.Domain,   
    Q.DocumentID,
    Q.Revision,
    ImportDocumentExists = case when ID.PrimKey is null then 0 else 1 end,
    ImportRevisionExists = case when IR.PrimKey is null then 0 else 1 end,
    ImportFileMetadata = case when RF.PrimKey is null then 0 else 1 end,
    ImportFileDownload = case when F.PrimKey is null then 0 else 1 end,
    ImportFileStorage = case when SF.PrimKey is null then 0 else 1 end,
    PimsDocumentExists = case when PD.PrimKey is null then 0 else 1 end,
    PimsRevisionExists = case when PR.PrimKey is null then 0 else 1 end
from
    @ErrorsOverTime Q -- hang everything off Q

    left join dbo.ltbl_Import_DTS_DCS_Documents as ID with (nolock)
        on ID.DCS_Domain = Q.Domain
        and ID.DCS_DocumentID = Q.DocumentID
    left join dbo.ltbl_Import_DTS_DCS_Revisions as IR with (nolock)
        on IR.DCS_Domain = Q.Domain
        and IR.DCS_DocumentID = Q.DocumentID
        and IR.DCS_Revision = Q.Revision

    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
        on RF.DCS_Domain = IR.DCS_Domain
        and RF.DCS_DocumentID = IR.DCS_DocumentID
        and RF.DCS_Revision = IR.DCS_Revision
    left join dbo.ltbl_Import_DTS_DCS_Files as F with (nolock)
        on F.object_guid = RF.object_guid
    left join dbo.stbl_System_Files as SF with (nolock)
        on SF.PrimKey = F.FileRef

    left join dbo.atbl_DCS_Documents as PD with (nolock)
        on PD.Domain = Q.Domain
        and PD.DocumentID = Q.DocumentID
    left join dbo.atbl_DCS_Revisions as PR with (nolock)
        on PD.Domain = Q.Domain
        and PR.DocumentID = Q.DocumentID
        and PR.Revision = Q.Revision

-- select * from @ImportExistence -- debug

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

select
    Pipeline = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock)
        where s.PrimKey = EOT.GroupRef
    ),
    EOT.BatchRef,
    EOT.Domain,
    EOT.DocumentID,
    EOT.Revision,
    EOT.ErrorDurationBatches,
    EOT.ObjectDurationDays,
    EOT.ObjectFirstSeen,
    EOT.ObjectLastSeen,
    IE.ImportDocumentExists,
    IE.ImportRevisionExists,
    IE.ImportFileMetadata,
    IE.ImportFileDownload,
    IE.ImportFileStorage,
    IE.PimsDocumentExists,
    IE.PimsRevisionExists,
    LE.object_guid,
    LE.originalFilename,
    LE.Message,
    LE.Created
from
    @ErrorsOverTime EOT

    join @ImportExistence IE
        on IE.GroupRef = EOT.GroupRef
        and IE.BatchRef = EOT.BatchRef
        and IE.Domain = EOT.Domain
        and IE.DocumentID = EOT.DocumentID
        and IE.Revision = EOT.Revision

    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles as IRF with (nolock)
        on IRF.INTEGR_REC_GROUPREF = EOT.GroupRef
        and IRF.INTEGR_REC_BATCHREF = EOT.BatchRef
        and IRF.DCS_Domain = EOT.Domain
        and IRF.DCS_DocumentID = EOT.DocumentID
        and IRF.DCS_Revision = EOT.Revision

    left join @LogEntries LE
        on LE.GroupRef = IRF.INTEGR_REC_GROUPREF
        and LE.BatchRef = IRF.INTEGR_REC_BATCHREF
        and LE.object_guid = IRF.object_guid

order by

    Domain,
    DocumentID

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
