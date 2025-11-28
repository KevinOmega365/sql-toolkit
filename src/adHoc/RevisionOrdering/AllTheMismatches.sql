

select
    Domain,
    DocumentID,
    DtsCurrentRevision,
    PimsCurrentRevision,
    MaxRevision
from
    (
        select
            Domain,
            DocumentID,
            DtsCurrentRevision,
            PimsCurrentRevision,
            MaxRevision = max(Revision)
        from
            (
                select
                    P.Domain,
                    P.DocumentID,
                    DtsCurrentRevision = I.currentRevision,
                    PimsCurrentRevision = P.CurrentRevision,
                    R.Revision
                from
                    dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
                    join dbo.atbl_DCS_Documents P with (nolock)
                        on P.Domain = I.DCS_Domain
                        and P.DocumentID = I.DCS_DocumentID
                    left join dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
                        on R.Domain = P.Domain
                        and R.DocumentID = P.DocumentID
            ) T
            group by
                Domain,
                DocumentID,
                DtsCurrentRevision,
                PimsCurrentRevision
    ) U
where
    isnull(DtsCurrentRevision, '') <> isnull(PimsCurrentRevision, '')
    or isnull(DtsCurrentRevision, '') <> isnull(MaxRevision, '')
    or isnull(MaxRevision, '') <> isnull(PimsCurrentRevision, '')
order by
    Domain,
    DocumentID
