declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'
declare
    @GroupRef uniqueidentifier = @Yggdrasil

select
    Count = count(*),
    Pipeline,
    Domain,
    DocumentStatus,
    revision,
    revisionStatus,
    reasonForIssue,
    PimsDocumentIsVoided,
    DCS_Step,
    DocumentImportStatus,
    RevisionImportStatus,
    DocumentExistsInPims,
    RevisionExistsInPims
from
(
    select
        Pipeline = (
            select Name
            from dbo.atbl_Integrations_ScheduledTasksConfigGroups G with (nolock)
            where G.Primkey = IR.INTEGR_REC_GROUPREF
        ),
        Domain = IR.DCS_Domain,
        DocumentStatus = ID.documentStatus,
        IR.revision,
        IR.revisionStatus,
        IR.reasonForIssue,
        PimsDocumentIsVoided = D.Voided,
        IR.DCS_Step,
        DocumentImportStatus = ID.INTEGR_REC_STATUS,
        RevisionImportStatus = IR.INTEGR_REC_STATUS,
        DocumentExistsInPims = cast(case
            when D.Primkey is null
            then 0
            else 1
        end as bit),
        RevisionExistsInPims = cast(case
            when R.Primkey is null
            then 0
            else 1
        end as bit)
    from
        dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
        join dbo.ltbl_Import_DTS_DCS_Documents ID with (nolock)
            on ID.DCS_Domain = IR.DCS_Domain
            and ID.DCS_DocumentID = IR.DCS_DocumentID
        left join dbo.atbl_DCS_Documents D with (nolock)
            on D.Domain = ID.DCS_Domain
            and D.DocumentID = ID.DCS_DocumentID
        left join dbo.atbl_DCS_Revisions R with (nolock)
            on R.Domain = IR.DCS_Domain
            and R.DocumentID = IR.DCS_DocumentID
            and R.Revision = IR.DCS_Revision
    where
        (
            IR.revision = 'V'
            or IR.revisionStatus = 'VOID'
            or IR.reasonForIssue in ('VOID', 'V')
        )
        -- and IR.INTEGR_REC_STATUS <> 'IGNORED'
) T
group by
    Pipeline,
    Domain,
    DocumentStatus,
    revision,
    revisionStatus,
    reasonForIssue,
    PimsDocumentIsVoided,
    DCS_Step,
    DocumentImportStatus,
    RevisionImportStatus,
    DocumentExistsInPims,
    RevisionExistsInPims
order by
    Pipeline,
    Domain,
    DocumentStatus,
    revision,
    revisionStatus,
    reasonForIssue,
    PimsDocumentIsVoided,
    DCS_Step,
    DocumentImportStatus,
    RevisionImportStatus,
    DocumentExistsInPims,
    RevisionExistsInPims
