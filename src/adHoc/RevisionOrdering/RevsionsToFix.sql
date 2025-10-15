select
    DocumentPrimkey,
    Domain,
    DocumentID,
    URL,
    CurrentRevision,
    HighestRevision,
    CurrentRevisionCreatedBy,
    HighestRevisionCreatedBy,
    CreationInterval = abs(datediff(second, CurrentRevisionCreated, HighestRevisionCreated)),
    CurrentRevisionCreated,
    HighestRevisionCreated,
    LastRevisionCreated,
    ProblemCount,
    ProblemDetails
from (
    select
        DocumentPrimkey = (
            select PrimKey
            from dbo.atbl_DCS_Documents D with (nolock)
            where
                D.Domain = U.Domain
                and D.DocumentID = U.DocumentID
        ),
        Domain,
        DocumentID,
        -- activate_link_document =
        --     '<a href="' +
        --     '/dcs-documents-details?Domain=' +
        --     D.Domain +
        --     '&DocID=' +
        --     D.DocumentID +
        --     '">' +
        --     D.DocumentID +
        --     '</a>',
        URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open "&B2)',
        CurrentRevision,
        HighestRevision,
        CurrentRevisionCreatedBy = (
            select CreatedBy
            from dbo.atbl_DCS_Revisions R with (nolock)
            where
                R.Domain = U.Domain
                and R.DocumentID = U.DocumentID
                and R.Revision = U.CurrentRevision
        ),
        HighestRevisionCreatedBy = (
            select CreatedBy
            from dbo.atbl_DCS_Revisions R with (nolock)
            where
                R.Domain = U.Domain
                and R.DocumentID = U.DocumentID
                and R.Revision = U.HighestRevision
        ),
        CurrentRevisionCreated = (
            select Created
            from dbo.atbl_DCS_Revisions R with (nolock)
            where
                R.Domain = U.Domain
                and R.DocumentID = U.DocumentID
                and R.Revision = U.CurrentRevision
        ),
        HighestRevisionCreated = (
            select Created
            from dbo.atbl_DCS_Revisions R with (nolock)
            where
                R.Domain = U.Domain
                and R.DocumentID = U.DocumentID
                and R.Revision = U.HighestRevision
        ),
        LastRevisionCreated,
        ProblemCount,
        ProblemDetails
    from (
        select
            Domain,
            DocumentID,
            CurrentRevision,
            HighestRevision,
            LastRevisionCreated,
            ProblemCount = count(*),
            ProblemDetails = '[ "' + string_agg(Problem, '", "') + '" ]'
        from
            (
                select
                    D.Domain,
                    D.DocumentID,            
                    D.CurrentRevision,
                    HighestRevision = max(R.Revision),
                    CurrentRevisionCreated = C.Created,
                    LastRevisionCreated = max(R.Created),
                    Problem = 'Highest numbered revision is greater then current revision'
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
                    D.Domain in (
                        select DCS_Domain
                        from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
                    )
                    AND isnumeric(C.Revision) = 1
                    AND isnumeric(R.Revision) = 1
                group by
                    D.Domain,
                    D.DocumentID,
                    D.CurrentRevision,
                    C.Created
                having
                    CurrentRevision < max(R.Revision)

            union all

                select
                    D.Domain,
                    D.DocumentID,
                    D.CurrentRevision,
                    HighestRevision = max(R.Revision),
                    CurrentRevisionCreated = C.Created,
                    LastRevisionCreated = max(R.Created),
                    Problem = 'Last created revision is later than current revision'
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
                    D.Domain in (
                        select DCS_Domain
                        from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
                    )
                group by
                    D.Domain,
                    D.DocumentID,
                    D.CurrentRevision,
                    C.Created
                having
                    C.Created < max(R.Created)
            ) T
        group by
            Domain,
            DocumentID,
            CurrentRevision,
            HighestRevision,
            CurrentRevisionCreated,
            LastRevisionCreated
    ) U
) V
where
    ProblemDetails like '%Highest numbered revision is greater then current revision%'

    and len(CurrentRevision) = 2
    and left(CurrentRevision, 1) = '0'
    and len(HighestRevision) = 2
    and left(HighestRevision, 1) = '0'

    and CurrentRevisionCreatedBy = 'af_Integrations_ServiceUser'
    and HighestRevisionCreatedBy = 'af_Integrations_ServiceUser'

    and abs(datediff(second, CurrentRevisionCreated, HighestRevisionCreated)) < 10000
