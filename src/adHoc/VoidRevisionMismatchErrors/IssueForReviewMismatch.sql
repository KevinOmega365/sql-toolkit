/* count of all documents in 128

snevre ned etter hva du ser etter


*/

/*
*
*/
SELECT sum(ReviewMismatch) FROM 
(SELECT * FROM 
(SELECT 
    SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo, T.Step, Sum(IsIssuedForReview) AS IsIssuedForReview,
    ABS(SUM(RequireReview) - SUM(IsIssuedForReview)) AS ReviewMismatch--, ABS(SUM(ForInfo) - SUM(IsIssuedForReview)) AS InfoMismatch
FROM 
(SELECT
    1 DocCountOne,
    RequireReview = cast(RequireReview as int),
    ForInfo = 1 - cast(RequireReview as int),
    R.Step, 
    IsIssuedForReview = CAST(R.IsIssuedForReview AS INT)
  FROM atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
    JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
        ON S.Step = R.Step
        AND S.Domain = R.Domain
    
    where D.Domain = '128') as T
    Group By Step) as U
WHERE IsIssuedForReview <> requireReview) AS V

-- difference between docs sent for review and missing review. 
SELECT * FROM 
(SELECT 
    SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo, T.Step, Sum(IsIssuedForReview) AS IsIssuedForReview,
    ABS(SUM(RequireReview) - SUM(IsIssuedForReview)) AS ReviewMismatch--, ABS(SUM(ForInfo) - SUM(IsIssuedForReview)) AS InfoMismatch
FROM 
(SELECT
    1 DocCountOne,
    RequireReview = cast(RequireReview as int),
    ForInfo = 1 - cast(RequireReview as int),
    R.Step, 
    IsIssuedForReview = CAST(R.IsIssuedForReview AS INT)
  FROM atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
    JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
        ON S.Step = R.Step
        AND S.Domain = R.Domain
    
    where D.Domain = '128') as T
    Group By Step) as U
WHERE IsIssuedForReview <> requireReview


-- avvik mellom Review og For Infor
SELECT * FROM 
(SELECT 
    SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo, T.Step, Sum(IsIssuedForReview) AS IsIssuedForReview
FROM 
(SELECT
    1 DocCountOne,
    RequireReview = cast(RequireReview as int),
    ForInfo = 1 - cast(RequireReview as int),
    R.Step, 
    IsIssuedForReview = CAST(R.IsIssuedForReview AS INT)
  FROM atbl_DCS_Documents AS D WITH (NOLOCK)
    JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.Currentrevision
    JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
        ON S.Step = R.Step
        AND S.Domain = R.Domain
    
    where D.Domain = '128') as T
    Group By Step) as U
WHERE IsIssuedForReview <> requireReview


-- R step is set for Info
-- SELECT * FROM 
-- (SELECT 
--     SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo, T.Step
-- FROM 
-- (SELECT
--     1 DocCountOne,
--     RequireReview = cast(RequireReview as int),
--     ForInfo = 1 - cast(RequireReview as int),
--     R.Step
--   FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
--         ON S.Step = R.Step
--         AND S.Domain = R.Domain
--     where D.Domain = '128') as T
--     Group By Step) as U
-- WHERE Step LIKE '%R' and ForInfo < 0

-- Count by different steps
-- SELECT 
--     SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo, T.Step
-- FROM 
-- (SELECT
--     1 DocCountOne,
--     RequireReview = cast(RequireReview as int),
--     ForInfo = 1 - cast(RequireReview as int),
--     R.Step
--   FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
--         ON S.Step = R.Step
--         AND S.Domain = R.Domain
--     where D.Domain = '128') as T
--     Group By Step

-- document count - reqired vs Info
-- SELECT SUM(docCountOne) AS DocCount, SUM(RequireReview) AS RequireReview, Sum(ForInfo) AS ForInfo FROM 
-- (SELECT
--     1 DocCountOne,
--     RequireReview = cast(RequireReview as int),
--     ForInfo = 1 - cast(RequireReview as int)
--   FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
--         ON S.Step = R.Step
--         AND S.Domain = R.Domain
--     where D.Domain = '128') as T


--require review
-- SELECT Count(*) FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
--         ON S.Step = R.Step
--         AND S.Domain = R.Domain
--     where D.Domain = '128'
    -- AND S.RequireReview = 1

-- all steps
-- SELECT Count(*) FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     JOIN atbl_DCS_Steps AS S WITH (NOLOCK)
--         ON S.Step = R.Step
--         AND S.Domain = R.Domain
--     where D.Domain = '128'

-- Alle dokumenter med current revision
-- SELECT Count(*) FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     JOIN atbl_dcs_Revisions AS R WITH (NOLOCk)
--         ON R.Domain = D.Domain
--         AND R.DocumentID = D.DocumentID
--         AND R.Revision = D.Currentrevision
--     where D.Domain = '128'


-- Alle dokumenter
-- SELECT 
--     COUNT(*)
--     FROM atbl_DCS_Documents AS D WITH (NOLOCK)
--     WHERE D.Domain = '128'