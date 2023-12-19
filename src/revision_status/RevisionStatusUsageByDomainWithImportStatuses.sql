/**
 * revision status usage by domain with import statuses
 */
SELECT
    Domain,
    Status,
    InstanceCount = SUM(InstanceCount),
    ImportStatusesIncluded = STRING_AGG(INTEGR_REC_STATUS, ', ')
FROM
(
    SELECT
        Domain = DCS_Domain,
        Status,
        INTEGR_REC_STATUS,
        InstanceCount = COUNT(*)
    FROM
        dbo.ltbl_Import_ProArc_Revisions WITH (NOLOCK)
    WHERE
        DCS_Domain is not null
    GROUP BY
        DCS_Domain,
        status,
        INTEGR_REC_STATUS
) T
GROUP BY
    Domain,
    status
ORDER BY
    Domain,
    status