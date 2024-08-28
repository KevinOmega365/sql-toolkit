declare @domain nvarchar(128) = '128'

/*
 * Total review mismatches
 */
SELECT
    SUM(ReviewMismatch)
FROM
    (
        SELECT
            *
        FROM
            (
                SELECT
                    ABS(SUM(RequireReview) - SUM(IsIssuedForReview)) AS ReviewMismatch,
                    Step,
                    SUM(DocCountOne) AS DocCount,
                    SUM(RequireReview) AS RequireReview,
                    SUM(ForInfo) AS ForInfo,
                    SUM(IsIssuedForReview) AS IsIssuedForReview
                FROM
                    (
                        SELECT
                            1 DocCountOne,
                            RequireReview = cast(RequireReview AS int),
                            ForInfo = 1 - cast(RequireReview AS int),
                            R.Step,
                            IsIssuedForReview = CAST(R.IsIssuedForReview AS INT)
                        FROM
                            dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
                            JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
                            ON R.Domain = D.Domain
                            AND R.DocumentID = D.DocumentID
                            AND R.Revision = D.Currentrevision
                            JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
                            ON S.Step = R.Step
                            AND S.Domain = R.Domain
                        WHERE
                            D.Domain = @domain
                    ) AS T
                GROUP BY
                    Step
            ) AS U
        WHERE
            IsIssuedForReview <> requireReview
    ) AS V

/*
 * Domain documents review mismatch counts by step
 */
SELECT
    *
FROM
    (
        SELECT
            ABS(SUM(RequireReview) - SUM(IsIssuedForReview)) AS ReviewMismatch,
            Step,
            SUM(DocCountOne) AS DocCount,
            SUM(RequireReview) AS RequireReview,
            SUM(ForInfo) AS ForInfo,
            SUM(IsIssuedForReview) AS IsIssuedForReview
        FROM
            (
                SELECT
                    1 DocCountOne,
                    RequireReview = cast(RequireReview AS int),
                    ForInfo = 1 - cast(RequireReview AS int),
                    R.Step,
                    IsIssuedForReview = CAST(R.IsIssuedForReview AS INT)
                FROM
                    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
                    JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
                    ON R.Domain = D.Domain
                    AND R.DocumentID = D.DocumentID
                    AND R.Revision = D.Currentrevision
                    JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
                    ON S.Step = R.Step
                    AND S.Domain = R.Domain
                WHERE
                    D.Domain = @domain
            ) AS T
        GROUP BY
            Step
    ) AS U
WHERE
    IsIssuedForReview <> requireReview

/*
 * Check step name matches review requirement
 */
SELECT
    *
FROM
    (
        SELECT
            SUM(DocCountOne) AS DocCount,
            SUM(RequireReview) AS RequireReview,
            SUM(ForInfo) AS ForInfo,
            T.Step
        FROM
            (
                SELECT
                    1 DocCountOne,
                    RequireReview = cast(RequireReview AS int),
                    ForInfo = 1 - cast(RequireReview AS int),
                    R.Step
                FROM
                    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
                    JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
                    ON R.Domain = D.Domain
                    AND R.DocumentID = D.DocumentID
                    AND R.Revision = D.Currentrevision
                    JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
                    ON S.Step = R.Step
                    AND S.Domain = R.Domain
                WHERE
                    D.Domain = @domain
            ) AS T
        GROUP BY
            Step
    ) AS U
WHERE
    Step LIKE '%R'  -- '%I'
    AND ForInfo > 0 -- RequireReview > 0

/*
 * Domain counts: documents, for review/info by step
 */
SELECT
    SUM(DocCountOne) AS DocCount,
    SUM(RequireReview) AS RequireReview,
    SUM(ForInfo) AS ForInfo,
    T.Step
FROM
    (
        SELECT
            1 DocCountOne,
            RequireReview = cast(RequireReview AS int),
            ForInfo = 1 - cast(RequireReview AS int),
            R.Step
        FROM
            dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
            JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
            ON R.Domain = D.Domain
            AND R.DocumentID = D.DocumentID
            AND R.Revision = D.Currentrevision
            JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
            ON S.Step = R.Step
            AND S.Domain = R.Domain
        WHERE
            D.Domain = @domain
    ) AS T
GROUP BY
    Step

/*
 * Domain counts: documents, for review/info
 */
SELECT
    SUM(DocCountOne) AS DocCount,
    SUM(RequireReview) AS RequireReview,
    SUM(ForInfo) AS ForInfo
FROM
    (
        SELECT
            1 DocCountOne,
            RequireReview = cast(RequireReview AS int),
            ForInfo = 1 - cast(RequireReview AS int)
        FROM
            dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
            JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
            ON R.Domain = D.Domain
            AND R.DocumentID = D.DocumentID
            AND R.Revision = D.Currentrevision
            JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
            ON S.Step = R.Step
            AND S.Domain = R.Domain
        WHERE
            D.Domain = @domain
    ) AS T

/*
 * Count all documents current revision with step config in domain
 */
SELECT
    Count(*)
FROM
    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
    JOIN dbo.atbl_DCS_Steps AS S WITH (NOLOCK)
        ON S.Domain = R.Domain
        AND S.Step = R.Step
WHERE
    D.Domain = @domain

/*
 * Count all documents current revision in domain
 */
SELECT
    Count(*)
FROM
    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN dbo.atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
WHERE
    D.Domain = @domain

/*
 * Count all documents in domain
 */
SELECT
    COUNT(*)
FROM
    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
WHERE
    D.Domain = @domain