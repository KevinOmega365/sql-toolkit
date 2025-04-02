SELECT
    R.Domain,
    OrphanedRevisions = COUNT(*)
FROM
    dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Revisions AS I WITH  (NOLOCK)
        ON I.DCS_Domain = R.Domain
        AND I.DCS_DocumentID = R.DocumentID
        AND I.DCS_Revision = R.Revision
WHERE
    I.PrimKey IS NULL
    AND R.Domain IN ('128', '145', '153', '187')
    AND R.CreatedBy = 'af_Integrations_ServiceUser'
GROUP BY
    R.Domain
