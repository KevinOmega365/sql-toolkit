/*
 * Superseding Document Lists
 */
SELECT
    TOP 10 *
FROM
    (
        SELECT
            Domain,
            activate_link_document = '<a href="' + '/dcs-documents-details?Domain=' + D.Domain + '&DocID=' + D.DocumentID + '">' + D.DocumentID + '</a>',
            SupersededDocumentIDs = (
                SELECT
                    '["' + STRING_AGG(SupersededDocumentID, '", "') + '"]'
                FROM
                    (
                        SELECT
                            SupersededDocumentID
                        FROM
                            dbo.atbl_DCS_SupersedingDocuments SD WITH (NOLOCK)
                        WHERE
                            SD.Domain = D.Domain
                            AND SD.SupersedingDocumentID = D.DocumentID
                    ) T
            ),
            SupersededDocumentIDCount = (
                SELECT
                    COUNT(*)
                FROM
                    dbo.atbl_DCS_SupersedingDocuments SD WITH (NOLOCK)
                WHERE
                    SD.Domain = D.Domain
                    AND SD.SupersedingDocumentID = D.DocumentID
            ),
            SupersedingDocumentIDs = (
                SELECT
                    '["' + STRING_AGG(SupersedingDocumentID, '", "') + '"]'
                FROM
                    (
                        SELECT
                            SupersedingDocumentID
                        FROM
                            dbo.atbl_DCS_SupersedingDocuments SD WITH (NOLOCK)
                        WHERE
                            SD.Domain = D.Domain
                            AND SD.SupersededDocumentID = D.DocumentID
                    ) T
            ),
            SupersedingDocumentCount = (
                SELECT
                    COUNT(*)
                FROM
                    dbo.atbl_DCS_SupersedingDocuments SD WITH (NOLOCK)
                WHERE
                    SD.Domain = D.Domain
                    AND SD.SupersededDocumentID = D.DocumentID
            )
        FROM
            dbo.aviw_DCS_API_Documents D
    ) AwesomeAlias
WHERE
    SupersedingDocumentCount > 0
    AND SupersededDocumentIDCount > 0
ORDER BY
    NEWID()

/*
 * Check counts
 */
-- SELECT
--     LeftJoin = (
--         SELECT
--             COUNT(*)
--         FROM
--             dbo.aviw_DCS_API_Documents D
--             LEFT JOIN dbo.atbl_DCS_SupersedingDocuments SD
--         WITH
--             (NOLOCK) ON SD.Domain = D.Domain
--             AND SD.SupersededDocumentID = D.DocumentID
--     ),
--     baseView = (
--         SELECT
--             COUNT(*)
--         FROM
--             dbo.aviw_DCS_API_Documents D
--     ),
--     Subselect = (
--         SELECT
--             COUNT(*)
--         FROM
--             (
--                 SELECT
--                     SupersedingDocumentCount = (
--                         SELECT
--                             COUNT(*)
--                         FROM
--                             dbo.atbl_DCS_SupersedingDocuments SD
--                         WITH
--                             (NOLOCK)
--                         WHERE
--                             SD.Domain = D.Domain
--                             AND SD.SupersededDocumentID = D.DocumentID
--                     )
--                 FROM
--                     dbo.aviw_DCS_API_Documents D
--             ) T
--     )
