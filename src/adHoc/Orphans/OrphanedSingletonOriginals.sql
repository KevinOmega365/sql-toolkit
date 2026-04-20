
/*
 * Orphaned Singleton Originals
 * Original or Name Files not present in the import
 * Created by our service user, but not the MIP import
 * In the current revision
 * and there is only one
 */

declare @GroupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'

-------------------------------------------------------------------------------

drop table if exists #ImportedFiles
;

create table #ImportedFiles (
    [DCS_Domain] [NVARCHAR] (128),
    [DCS_DocumentID] [NVARCHAR] (50),
    [DCS_RevisionItemNo] [INT],
    [DCS_OriginalFileName] [NVARCHAR] (256)
)
;

create clustered index ImportedFiles_Keys on #ImportedFiles (
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_OriginalFileName
)
;

insert into
    #ImportedFiles
select
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_OriginalFilename
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
where
    INTEGR_REC_GROUPREF = @GroupRef
;

update statistics #ImportedFiles
;

-------------------------------------------------------------------------------

select
    RF.Domain,
    RF.DocumentID,
    R.Revision,
    URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open")',
    RF.OriginalFilename,
    RF.FileDescription,
    ImportDocExists = cast(case when ImportedDocuments.Primkey is null then 0 else 1 end as bit),
    ImportRevExists = cast(case when ImportedRevisions.Primkey is null then 0 else 1 end as bit)
from
    (
        select
            R.Domain,
            R.DocumentID,
            R.RevisionItemNo,
            R.Revision
        from
            dbo.atbl_DCS_Documents D with (nolock)
            join dbo.atbl_DCS_Revisions R with (nolock)
                on R.Domain = D.Domain
                and R.DocumentID = D.DocumentID
            join dbo.atbl_DCS_RevisionsFiles RF with (nolock)
                on RF.Domain = R.Domain
                and RF.DocumentID = R.DocumentID
                and RF.RevisionItemNo = R.RevisionItemNo
        where
            RF.Domain in ('128', '187')
            and R.Revision not in ('V', 'S')
            and RF.Type in ('Original', 'Native')
            and RF.CreatedBy = 'af_Integrations_ServiceUser'
            -- and RF.FileDescription not like '#%'
            and RF.FileDescription not like 'FROM MIPS%'
        group by
            R.Domain,
            R.DocumentID,
            R.RevisionItemNo,
            R.Revision
        having
            count(*) = 1
    ) as R
    join (
        select
            RF.Domain,
            RF.DocumentID,
            RF.Revision_ID,
            RF.RevisionItemNo,
            RF.OriginalFilename,
            RF.FileRef,
            RF.FileDescription
        from
            dbo.atbl_DCS_Documents as D with (nolock)
            join dbo.atbl_DCS_Revisions as R with (nolock)
                on R.ID = D.CurrentRevision_ID
            join dbo.atbl_DCS_RevisionsFiles as RF with (nolock)
                on RF.Revision_ID = R.ID
        where
            RF.Domain in ('128', '187')
            and R.Revision not in ('V', 'S')
            and RF.Type in ('Original', 'Native')
            and RF.CreatedBy = 'af_Integrations_ServiceUser'
            -- and RF.FileDescription not like '#%'
            and RF.FileDescription not like 'FROM MIPS%'
    ) as RF
        on RF.Domain = R.Domain
        and RF.DocumentID = R.DocumentID
        and RF.RevisionItemNo = R.RevisionItemNo
    left join (
        select
            DCS_Domain,
            DCS_DocumentID,
            Primkey
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        where
            INTEGR_REC_GROUPREF = @GroupRef
    ) as ImportedDocuments
        on ImportedDocuments.DCS_Domain  = RF.Domain
        and ImportedDocuments.DCS_DocumentID  = RF.DocumentID
    left join (
        select
            DCS_Domain,
            DCS_DocumentID,
            DCS_Revision,
            Primkey
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @GroupRef
    ) as ImportedRevisions
        on ImportedRevisions.DCS_Domain  = RF.Domain
        and ImportedRevisions.DCS_DocumentID  = RF.DocumentID
        and ImportedRevisions.DCS_Revision  = R.Revision
where
    not exists (
        select *
        from #ImportedFiles as IRF
        where
            IRF.DCS_Domain COLLATE Latin1_General_CI_AS = RF.Domain
            and IRF.DCS_DocumentID COLLATE Latin1_General_CI_AS = RF.DocumentID
            and IRF.DCS_RevisionItemNo = RF.RevisionItemNo
            and IRF.DCS_OriginalFilename COLLATE Latin1_General_CI_AS = (
                case
                    when RF.OriginalFilename like 'TEMP_NAME_%' -- WTEL...F!
                    then right(RF.OriginalFilename, len(RF.OriginalFilename) - len('TEMP_NAME_'))
                    else RF.OriginalFilename
                end
            )
    )
order by
    RF.Domain,
    RF.DocumentID,
    R.Revision
;

-------------------------------------------------------------------------------
