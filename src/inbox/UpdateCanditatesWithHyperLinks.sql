
/*
Active Link Bookmarklet

Usage: Create a bookmark and set the next line as the URL

javascript:(()=>{[...document.querySelector("iframe.active").contentWindow.document.querySelectorAll('[data-field^=activate_link]')].forEach(e=>{const p=e.parentElement;p.innerHTML=e.value;});})();

If a colum alias starts with "activate_link" the text in the column will rendered as html

[Works in Pims R4]
*/

/**
 * Pick N candidates
 */
DECLARE @TargetRevisions table (
    RevisionRef UNIQUEIDENTIFIER
)
INSERT INTO @TargetRevisions
SELECT TOP 50 Pims.PrimKey
FROM
    dbo.atbl_DCS_Revisions Pims WITH (NOLOCK)
    JOIN dbo.ltbl_Import_ProArc_Revisions ProArc WITH (NOLOCK)
        ON ProArc.DCS_Domain = Pims.Domain
        AND ProArc.document_number = Pims.DocumentID
        AND ProArc.revision = Pims.Revision
WHERE
    ISNULL(Pims.ContractorSupplierAcceptanceCode, '') <> ISNULL(ProArc.DCS_ContractorSupplierAcceptanceCode, '')
ORDER BY
    NEWID()

/**
 * Get the reference(s)
 */
SELECT
    activate_link_document =
        '<a href="' +
        'https://pims.akerbp.com/dcs-documents-details?Domain=' +
        Pims.Domain +
        '&DocID=' +
        Pims.DocumentID +
        '">' +
        DocumentID +
        '</a>',
    Pims.Domain,
    Pims.DocumentID,
    Pims.Revision,
    Pims.ContractorSupplierAcceptanceCode,
    ProArc.DCS_ContractorSupplierAcceptanceCode,
    Pims.PrimKey
FROM
    dbo.atbl_DCS_Revisions Pims WITH (NOLOCK)
    JOIN dbo.ltbl_Import_ProArc_Revisions ProArc WITH (NOLOCK)
        ON ProArc.DCS_Domain = Pims.Domain
        AND ProArc.document_number = Pims.DocumentID
        AND ProArc.revision = Pims.Revision
WHERE
    Pims.PrimKey IN
    (
        SELECT RevisionRef FROM @TargetRevisions
    )

/**
 * Update the value
 */
/* disarmed
-- UPDATE Pims
-- SET
--     Pims.ContractorSupplierAcceptanceCode = ProArc.DCS_ContractorSupplierAcceptanceCode
-- FROM
--     dbo.atbl_DCS_Revisions Pims WITH (NOLOCK)
--     JOIN dbo.ltbl_Import_ProArc_Revisions ProArc WITH (NOLOCK)
--         ON ProArc.DCS_Domain = Pims.Domain
--         AND ProArc.document_number = Pims.DocumentID
--         AND ProArc.revision = Pims.Revision
-- WHERE
--     Pims.PrimKey IN
--     (
--         SELECT RevisionRef FROM @TargetRevisions
--     )
*/