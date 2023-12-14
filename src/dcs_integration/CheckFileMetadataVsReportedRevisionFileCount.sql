select
    Domain,
    DocumentID,
    Revision,
    RevsionImportStatus,
    FileCount,
    ReportedFileCount
from
    (
        select
            Domain = R.DCS_Domain,
            DocumentID = R.document_number,
            Revision = R.revision,
            RevsionImportStatus = R.INTEGR_REC_STATUS,
            FileCount = (
                select count(*)
                from
                    dbo.ltbl_Import_ProArc_RevisionFiles RF with (nolock)
                where
                    RF.DCS_Domain = R.DCS_Domain
                    and RF.document_number = R.document_number
                    and RF.revision = R.revision
            ),
            ReportedFileCount = files_exists
        from
            dbo.ltbl_Import_ProArc_Revisions R with (nolock)
        where
            r.INTEGR_REC_ERROR = 'Quality Failure: Revision without Files'
    ) T
    join (
        select DocId, Rev
        from (
            values
                ('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION') --, ...
            ) as T (DocId, Rev)
    ) U
        on U.DocId = T.DocumentID
        and U.Rev = T.Revision
-- where
--     FileCount > 0
order by
    Domain,
    DocumentID,
    Revision