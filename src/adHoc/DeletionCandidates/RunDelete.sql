/*
    execute dbo.lstp_Integrations_DTS_DCS_DeleteDocuments
            @BatchSize = 100
*/
select
    INTEGR_REC_STATUS,
    INTEGR_REC_ERROR,
    count(*) as Count
from
    dbo.ltbl_integrations_DCS_DocsDeletionCandidates with (nolock)
group by
    INTEGR_REC_STATUS,
    INTEGR_REC_ERROR
