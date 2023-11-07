/**
 * Check a list of revisions against the import table
 */
select
    R.DCS_Domain,
    R.document_number,
    R.revision,
    R.status,
    R.INTEGR_REC_ERROR,
    R.INTEGR_REC_STATUS,
    R.INTEGR_REC_TRACE
from
    dbo.ltbl_Import_ProArc_Revisions as R with (nolock)
    join (
        select
            DocumentID,
            Revision
        from
        (
            values
                ('FPQ-AKSO-Z-LA-00005', '04'),
                ('FPQ-LR031-XD-00004-01', '01'),
                ('FPQ-ENS-A-KA-00012', '03'),
                ('FPQ-ENS-A-LA-00001', '02'),
                ('FPQ-AKSO-C-LA-00406', '03'),
                ('FPQ-ENS-M-KA-00003', '01'),
                ('FPQ-ENS-M-KA-00005', '01'),
                ('FPQ-AKSO-I-XL-24001-01', '02'),
                ('FPQ-AKSO-I-XL-24005-01', '01')
        ) T
        (
            DocumentID,
            Revision
        )
    ) ProblemDocuments
        on ProblemDocuments.DocumentID = R.document_number
        and ProblemDocuments.Revision = R.revision
order by
    R.document_number,
    R.revision