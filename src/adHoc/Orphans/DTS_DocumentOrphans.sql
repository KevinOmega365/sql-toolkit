
/*
 * Orphaned Documents Count By Domain, revision count and revision-file count
 */
-- SELECT
--     T.Domain,
--     T.RevisionCount,
--     T.RevisionFileCount,
--     OrphanedDocuments = COUNT(*)
-- FROM
-- (
--     SELECT
--         D.Domain,
--         D.DocumentID,
--         RevisionCount = ( -- can be zero
--             SELECT COUNT(*)
--             FROM dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--             WHERE
--                 R.Domain = D.Domain
--                 AND R.DocumentID = D.DocumentID
--         ),
--         RevisionFileCount = ( -- can be zero
--             SELECT COUNT(*)
--             FROM
--                 dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--                 JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
--                     ON RF.Domain = R.Domain
--                     AND RF.DocumentID = R.DocumentID
--                     AND RF.RevisionItemNo = R.RevisionItemNo
--             WHERE
--                 R.Domain = D.Domain
--                 AND R.DocumentID = D.DocumentID
--         )
--     FROM
--         dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
--         LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
--             ON D.Domain = I.DCS_Domain
--             AND D.DocumentID = I.DCS_DocumentID
--     WHERE
--         I.PrimKey IS NULL
--         AND D.Domain IN ('128', '145', '153', '187')
--         AND D.CreatedBy = 'af_Integrations_ServiceUser'
--     GROUP BY
--         D.Domain,
--         D.DocumentID
-- ) T
-- GROUP BY
--     T.Domain,
--     T.RevisionCount,
--     T.RevisionFileCount
-- ORDER BY
--     T.Domain,
--     T.RevisionCount,
--     T.RevisionFileCount

/*
 * Document List
 * Inlcudes links for
 *   af-dbmanager (bookmarklet) and
 *   Excel (activate and copy down {ctrl+shift+end; ctrl+d})
 */ 
-- DECLARE @Domain NVARCHAR(128) = '145'
-- SELECT
--     -- -- live links in af-db-manager
--     -- activate_link_document =
--     --     '<a href="' +
--     --     'https://pims.akerbp.com/dcs-documents-details?Domain=' +
--     --     D.Domain +
--     --     '&DocID=' +
--     --     D.DocumentID +
--     --     '">' +
--     --     D.DocumentID +
--     --     '</a>',
--     D.Domain,
--     D.DocumentID,
--     RevisionCount = ( -- can be zero
--         SELECT COUNT(*)
--         FROM dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--         WHERE
--             R.Domain = D.Domain
--             AND R.DocumentID = D.DocumentID
--     ),
--     RevisionFileCount = ( -- can be zero
--         SELECT COUNT(*)
--         FROM
--             dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--             JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
--                 ON RF.Domain = R.Domain
--                 AND RF.DocumentID = R.DocumentID
--                 AND RF.RevisionItemNo = R.RevisionItemNo
--         WHERE
--             R.Domain = D.Domain
--             AND R.DocumentID = D.DocumentID
--     ),
--     IsVoided,
--     IsSuperseded
--     -- , URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)'
-- FROM
--     dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
--     LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
--         ON D.Domain = I.DCS_Domain
--         AND D.DocumentID = I.DCS_DocumentID
-- WHERE
--     I.PrimKey IS NULL
--     AND D.Domain IN ('128', '145', '153', '187')
--     AND D.CreatedBy = 'af_Integrations_ServiceUser'
--     AND D.Domain LIKE @Domain


/*
 * Orphaned Documents Count by Domain
 */
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