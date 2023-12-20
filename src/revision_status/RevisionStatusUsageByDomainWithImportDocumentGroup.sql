/**
 * revision status usage by domain with document group
 */
SELECT
    Domain,
    Status,
    InstanceCount = SUM(InstanceCount),
    ImportStatusesIncluded = STRING_AGG(DocumentGroup, ', ')
FROM
(
    SELECT
        Domain = R.DCS_Domain,
        R.Status,
        DocumentGroup = D.DCS_DocumentGroup,
        InstanceCount = COUNT(*)
    FROM
        dbo.ltbl_Import_ProArc_Revisions R WITH (NOLOCK)
        JOIN dbo.ltbl_Import_ProArc_Documents D WITH (NOLOCK)
            ON D.DCS_Domain = R.DCS_Domain
            AND D.document_number = R.document_number
    WHERE
        R.DCS_Domain is not null
    GROUP BY
        R.DCS_Domain,
        R.status,
        D.DCS_DocumentGroup
) T
GROUP BY
    Domain,
    status
ORDER BY
    Domain,
    status