declare @domain nvarchar(128) = '128'

/*
 * List documents where IsIssuedForReview does not match RequireReview for domain
 */
SELECT
    D.Domain,
    D.DocumentID,
    D.CurrentRevision AS Revision,
    R.Step,
    RequireReview,
    IsIssuedForReview
FROM
    atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
    JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
        ON S.Step = R.Step
        AND S.Domain = R.Domain
WHERE
    D.Domain = @domain
    AND IsIssuedForReview <> RequireReview