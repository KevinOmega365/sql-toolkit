select
    Domain,
    DocumentID
into
    #SampleDocuments
from
    dbo.atbl_DCS_Documents with (nolock)
where
    Domain in ('128', '187')

/*
 * "historical" revisions out of order
 */
select
    Domain,
    DocumentID,
    URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open")',
    Revisions = DateOrder,
    Details
from
(
    select
        S.Domain,
        S.DocumentID,
        DateOrder = DescendingRevisionDateOrder.Revisions,
        NaturalOrder = DescendingRevisionNaturalOrder.Revisions,
        Details = DescendingRevisionDateOrder.RevisionsVerbose
    from
        #SampleDocuments S
        join (
            select
                R.Domain,
                R.DocumentID,
                Revisions =
                    string_agg(Revision, ', ')
                    within group (order by RevisionDate desc),
                RevisionsVerbose =
                    '[' +
                        string_agg('["' + (Revision + '", "' +  convert(nvarchar(max), RevisionDate, 23) + '"]'), ', ')
                            within group (order by RevisionDate desc)
                    + ']'
            from
                dbo.atbl_DCS_Revisions R with (nolock)
                join #SampleDocuments S
                    on S.Domain = R.Domain
                    and S.DocumentID = R.DocumentID
            group by
                R.Domain,
                R.DocumentID
        ) DescendingRevisionDateOrder
            on DescendingRevisionDateOrder.Domain = S.Domain
            and DescendingRevisionDateOrder.DocumentID = S.DocumentID
        join (
            select
                R.Domain,
                R.DocumentID,
                Revisions =
                    string_agg(Revision, ', ')
                        within group (order by Revision desc)
            from
                dbo.atbl_DCS_Revisions R with (nolock)
                join #SampleDocuments S
                    on S.Domain = R.Domain
                    and S.DocumentID = R.DocumentID
            group by
                R.Domain,
                R.DocumentID
        ) DescendingRevisionNaturalOrder
            on DescendingRevisionNaturalOrder.Domain = S.Domain
            and DescendingRevisionNaturalOrder.DocumentID = S.DocumentID
) T
where
    NaturalOrder <> DateOrder
order by
    Domain,
    DocumentID