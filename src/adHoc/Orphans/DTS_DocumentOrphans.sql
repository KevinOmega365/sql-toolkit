
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Valhall -- '%'

declare @DomainList table (
    DCS_Domain nvarchar(128)
)
insert into @DomainList
select DCS_Domain
from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
where INTEGR_REC_GROUPREF like @GroupRef

/*
 * Orphaned Documents Count By Domain, revision count and revision-file count
 */
SELECT
    T.Domain,
    T.RevisionCount,
    T.RevisionFileCount,
    OrphanedDocuments = COUNT(*)
FROM
(
    SELECT
        D.Domain,
        D.DocumentID,
        RevisionCount = ( -- can be zero
            SELECT COUNT(*)
            FROM dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            WHERE
                R.Domain = D.Domain
                AND R.DocumentID = D.DocumentID
        ),
        RevisionFileCount = ( -- can be zero
            SELECT COUNT(*)
            FROM
                dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
                JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
                    ON RF.Domain = R.Domain
                    AND RF.DocumentID = R.DocumentID
                    AND RF.RevisionItemNo = R.RevisionItemNo
            WHERE
                R.Domain = D.Domain
                AND R.DocumentID = D.DocumentID
        )
    FROM
        dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
        LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
            ON D.Domain = I.DCS_Domain
            AND D.DocumentID = I.DCS_DocumentID
    WHERE
        I.PrimKey IS NULL
        AND D.Domain IN (select DCS_Domain from @DomainList)
        AND D.CreatedBy = 'af_Integrations_ServiceUser'
    GROUP BY
        D.Domain,
        D.DocumentID
) T
GROUP BY
    T.Domain,
    T.RevisionCount,
    T.RevisionFileCount
ORDER BY
    T.Domain,
    T.RevisionCount,
    T.RevisionFileCount

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
--     -- , URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open "&B2)'
-- FROM
--     dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
--     LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
--         ON D.Domain = I.DCS_Domain
--         AND D.DocumentID = I.DCS_DocumentID
-- WHERE
--     I.PrimKey IS NULL
--     AND D.Domain IN (select DCS_Domain from @DomainList)
--     AND D.CreatedBy = 'af_Integrations_ServiceUser'


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
    AND D.Domain IN (select DCS_Domain from @DomainList)
    AND D.CreatedBy = 'af_Integrations_ServiceUser'
GROUP BY
    Domain
