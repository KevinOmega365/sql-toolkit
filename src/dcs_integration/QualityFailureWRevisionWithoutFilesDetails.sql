select
    Domain = R.DCS_Domain,
    DocumentID = R.document_number,
    Revision = R.revision,
    FileCount = count(*),
    FilesNames = '["' + string_agg(isnull(RF.original_filename, ''), '", "') + '"]',
    FilesComments = '["' + string_agg(isnull(RF.file_comment, ''), '", "') + '"]',
    FilesTrace = '[' + string_agg(RF.INTEGR_REC_TRACE, ', ') + ']'
from
    dbo.ltbl_Import_ProArc_Revisions R with (nolock)
    join dbo.ltbl_Import_ProArc_RevisionFiles RF with (nolock)
        on RF.DCS_Domain = R.DCS_Domain
        and RF.document_number = R.document_number
        and RF.revision = R.revision
where
    r.INTEGR_REC_ERROR = 'Quality Failure: Revision without Files'
group by
    R.DCS_Domain,
    R.document_number,
    R.revision
order by
    Domain,
    DocumentID,
    Revision