/*
 * Withdrawn documents (?)
 */
select
    Domain,
    DocumentID
FROM
    dbo.atbl_DCS_Documents AS DCS WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_BMS_Documents AS I WITH (NOLOCK)
        ON I.DCS_Domain = DCS.Domain
        AND I.DCS_DocumentID = DCS.DocumentID
WHERE
    DCS.Domain = 'PRO'
    and I.DCS_DocumentID IS NULL
    and DCS.CreatedBy = 'af_Integrations_ServiceUser'
