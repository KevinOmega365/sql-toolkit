
drop table if exists #Domains

select distinct DCS_Domain
into #Domains
from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)

-------------------------------------------------------------------------------

select
    P.Domain,
    P.DocumentID,
    URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open "&B2)',
    DtsCurrentRevision = I.currentRevision,
    PimsCurrentRevision = P.CurrentRevision,
    PimsHighestRevision = P.HighestRevision,
    RevisionHistoryDesc =
        '["' + (
            select
                string_agg(Revision, '", "') within group (order by Created desc)
            from (
                select
                    Revision,
                    Created
                from
                    dbo.atbl_DCS_Revisions R with (nolock)
                where
                    R.Domain = P.Domain
                    and R.DocumentID = P.DocumentID
            ) as T
        ) + '"]',
    RevisionHistorVerbose =
        '[' + (
            select
                string_agg('["' + Revision + '", "' + convert(nchar(10), Created, 23) + '"]', ', ')
                    within group (order by Created desc)
            from (
                select
                    Revision,
                    Created
                from
                    dbo.atbl_DCS_Revisions R with (nolock)
                where
                    R.Domain = P.Domain
                    and R.DocumentID = P.DocumentID
            ) as T
        ) + ']'
from
    dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
    join (
        select
            D.Domain,
            D.DocumentID,            
            D.CurrentRevision,
            HighestRevision = max(R.Revision)
        from           
            dbo.atbl_DCS_Documents D with (nolock)
            join dbo.atbl_DCS_Revisions R with (nolock)
                on R.Domain = D.Domain
                and R.DocumentID = D.DocumentID
            join dbo.atbl_DCS_Revisions C with (nolock)
                on C.Domain = D.Domain
                and C.DocumentID = D.DocumentID
                and C.Revision = D.CurrentRevision
        where
            D.Domain in (select DCS_Domain from #Domains)

            AND isnumeric(C.Revision) = 1
            AND isnumeric(R.Revision) = 1

        group by
            D.Domain,
            D.DocumentID,
            D.CurrentRevision,
            C.Created
        having
            CurrentRevision < max(R.Revision)
    ) P
        on P.Domain = I.DCS_Domain
        and P.DocumentID = I.DCS_DocumentID
where
    isnull(I.currentRevision, '') <> isnull(P.CurrentRevision, '')
    or isnull(P.CurrentRevision, '') <> isnull(P.HighestRevision, '')
order by
    P.Domain,
    P.DocumentID

-------------------------------------------------------------------------------
