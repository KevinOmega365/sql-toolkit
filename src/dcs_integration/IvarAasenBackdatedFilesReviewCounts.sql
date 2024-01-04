SELECT 
    Total = sum(Subtotal),
    RevisionExistsInPims = sum(RevisionExistsInPims),
    ReviewExistsInPims = sum(ReviewExistsInPims),
    ReviewIsClosed = sum(ReviewIsClosed)
FROM (
    SELECT 
        MAR.DCS_DocumentID,
        Subtotal = 1,
        RevisionExistsInPims = case when R.Primkey is null then 0 else 1 end,
        ReviewExistsInPims = case when R.IsIssuedForReview is null then 0 else 1 end,
        ReviewIsClosed = CASE WHEN R.ReviewFinalized IS NULL THEN 0 ELSE 1 END
    FROM
        dbo.ltbl_Import_MuninAibel_RevisionFiles RF WITH (NOLOCK)
        LEFT JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK) 
            ON R.Revision = RF.DCS_Revision
            AND R.Domain = RF.DCS_Domain
            AND R.DocumentID = RF.DCS_DocumentID
        LEFT JOIN dbo.ltbl_Import_MuninAibel_Revisions AS MAR WITH (NOLOCK)
            ON MAR.Revision = RF.Revision
            AND MAR.DCS_Domain = RF.DCS_Domain
            AND MAR.DCS_DocumentID = RF.DCS_DocumentID
        WHERE
            (
                RF.INTEGR_REC_STATUS = 'OUT_OF_SCOPE' OR
                MAR.INTEGR_REC_STATUS = 'QUALITY_CHECK_FAILED'
            )
            AND RF.DCS_Domain = '181'
) AS AllFiles