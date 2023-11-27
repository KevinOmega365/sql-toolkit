/**
 * Chain and reason for issue distribution
 */

DECLARE
    @Domain NVARCHAR(128) = '175',
    @DocumentGroup NVARCHAR(16) = '%' -- 'ENGINEERING'

SELECT
    Count = COUNT(*),
    D.DCS_Domain,
    D.chain,
    R.reasonForIssue,
    D.DCS_Criticality,
    D.DCS_DocumentGroup
FROM
    dbo.ltbl_Import_MuninAibel_Documents D WITH (NOLOCK)
    JOIN dbo.ltbl_Import_MuninAibel_Revisions R WITH (NOLOCK)
        ON R.DCS_Domain = D.DCS_Domain
        AND R.DCS_DocumentID = D.DCS_DocumentID
        AND R.INTEGR_REC_BATCHREF = D.INTEGR_REC_BATCHREF
WHERE
    D.DCS_Domain like @Domain
    and D.DCS_DocumentGroup like @DocumentGroup
GROUP BY
    D.DCS_Domain,
    D.chain,
    R.reasonForIssue,
    D.DCS_Criticality,
    D.DCS_DocumentGroup
ORDER BY
    D.DCS_Domain,
    D.chain,
    R.reasonForIssue