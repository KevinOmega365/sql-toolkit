
declare @domain nvarchar(128) = '175' -- '128' --

select
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
    CurrentRevisionCreated,
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
            D.Domain = @domain
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
            D.Domain = @domain
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
