SELECT
    D.Domain,
    OrphanedDocuments = COUNT(*)
FROM
    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
        ON D.Domain = I.DCS_Domain
        AND D.DocumentID = I.DCS_DocumentID
WHERE
    I.PrimKey IS NULL
    AND D.Domain IN ('128', '145', '153', '187')
    AND D.CreatedBy = 'af_Integrations_ServiceUser'
GROUP BY
    Domain
