select
    C.Domain,
    C.DocumentID,
    C.MirroringDomain,
    C.Title,
    C.INTEGR_REC_STATUS,
    C.INTEGR_REC_ERROR,
    DocumentExists = cast (case when D.PrimKey is null then 0 else 1 end as bit),
    MirroringDocumentExists = cast (case when M.PrimKey is null then 0 else 1 end as bit)
    , URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)'
from
    dbo.ltbl_integrations_DCS_DocsDeletionCandidates C with (nolock)
    left join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = C.Domain
        and D.DocumentID = C.DocumentID
    left join dbo.atbl_DCS_Documents M with (nolock)
        on M.Domain = C.MirroringDomain
        and M.DocumentID = C.DocumentID
where
    C.INTEGR_REC_ERROR is not null
order by
    C.Domain,
    C.DocumentID