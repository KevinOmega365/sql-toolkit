/**
 * Compare Mapping vs Import
 */
SELECT
    ChainsChain = Chains.chain,
    ChainsReasonForIssue = Chains.reasonForIssue,
    ImportChain = Import.chain,
    ImportReasonForIssue = Import.reasonForIssue,
    Import.InstanceCount
FROM
    (
        SELECT
            chain,
            reasonForIssue
        FROM
            dbo.ltbl_Import_Mapping_ProArcChains WITH (NOLOCK)
        WHERE
            Domain = '175'
    )
    Chains
    FULL OUTER JOIN
    (
        SELECT
            chain,
            reasonForIssue,
            InstanceCount = count(*)
        FROM
            dbo.ltbl_Import_MuninAibel_Documents D WITH (NOLOCK)
            JOIN dbo.ltbl_Import_MuninAibel_Revisions R WITH (NOLOCK)
                ON R.DCS_Domain = D.DCS_Domain
                AND R.DCS_DocumentID = D.DCS_DocumentID
        WHERE
            chain IS NOT NULL
        GROUP BY
            chain,
            reasonForIssue
    ) Import
        ON Import.chain = Chains.chain
        AND Import.reasonForIssue = Chains.reasonForIssue
ORDER BY
    Chains.chain,
    Chains.reasonForIssue
