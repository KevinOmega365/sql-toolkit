/*
 * PrimKeys to delete
 */
SELECT Primkey
FROM
    (
        SELECT
            Sort = row_number() over (partition by Domain, DocumentID, RevisionItemNo order by IsShared desc, IsInImport desc, Created), -- To Keep Priority
            T.*
        FROM
        (
            SELECT
                RF.PrimKey,
                Created,
                CreatedBY,
                RF.Domain,
                RF.DocumentID,
                activate_link_document = '<a href="' + '/dcs-documents-details?Domain=' + RF.Domain + '&DocID=' + RF.DocumentID + '">' + RF.DocumentID + '</a>',
                RF.RevisionItemNo,
                RF.FileRef,
                IsInImport = case
                    when EXISTS (
                        SELECT *
                        FROM dbo.ltbl_Import_BMS_RevisionFiles AS I WITH (NOLOCK)
                        WHERE I.DCS_FileRef = RF.FileRef
                    )
                    then 1
                    else 0
                end,
                IsInImportFiles = case
                    when EXISTS (
                        SELECT *
                        FROM dbo.ltbl_Import_BMS_Files AS I WITH (NOLOCK)
                        WHERE I.FileRef = RF.FileRef
                    )
                    then 1
                    else 0
                end,
                IsShared =  case
                    when EXISTS (
                        SELECT *
                        FROM dbo.atbl_DCS_SharedDocumentsFiles AS DcsSharedFiles WITH (NOLOCK)
                        WHERE DcsSharedFiles.RevisionFilePrimKey = RF.PrimKey
                    )
                    then 1
                    else 0
                end
            FROM
                dbo.atbl_DCS_RevisionsFiles RF with (nolock)
                INNER JOIN (
                    SELECT
                        Domain,
                        DocumentID,
                        RevisionItemNo,
                        FileRef
                    FROM
                        dbo.atbl_DCS_RevisionsFiles with (nolock)
                    WHERE
                        Domain = 'PRO'
                    GROUP BY
                        Domain,
                        DocumentID,
                        RevisionItemNo,
                        FileRef
                    HAVING
                        COUNT(*) > 1
                ) dup ON RF.FileRef = dup.FileRef
            WHERE
                RF.Domain = 'PRO'
        ) T
    ) U
WHERE
    Sort > 1
ORDER BY
    Domain,
    DocumentID,
    RevisionItemNo,
    FileRef,
    Created
/*
 * Duplicates (with import information)
 */
-- SELECT
--     Sort = row_number() over (partition by RF.Domain, RF.DocumentID, RF.RevisionItemNo order by Created),
--     RF.PrimKey,
--     Created,
--     CreatedBY,
--     RF.Domain,
--     RF.DocumentID,
--     activate_link_document = '<a href="' + '/dcs-documents-details?Domain=' + RF.Domain + '&DocID=' + RF.DocumentID + '">' + RF.DocumentID + '</a>',
--     RF.RevisionItemNo,
--     RF.FileRef,
--     IsInImport = case
--         when EXISTS (
--             SELECT *
--             FROM dbo.ltbl_Import_BMS_RevisionFiles AS I WITH (NOLOCK)
--             WHERE I.DCS_FileRef = RF.FileRef
--         )
--         then 1
--         else 0
--     end,
--     IsInImportFiles = case
--         when EXISTS (
--             SELECT *
--             FROM dbo.ltbl_Import_BMS_Files AS I WITH (NOLOCK)
--             WHERE I.FileRef = RF.FileRef
--         )
--         then 1
--         else 0
--     end,
--     IsShared =  case
--         when EXISTS (
--             SELECT *
--             FROM dbo.atbl_DCS_SharedDocumentsFiles AS DcsSharedFiles WITH (NOLOCK)
--             WHERE DcsSharedFiles.RevisionFilePrimKey = RF.PrimKey
--         )
--         then 1
--         else 0
--     end
-- FROM
--     dbo.atbl_DCS_RevisionsFiles RF with (nolock)
--     INNER JOIN (
--         SELECT
--             Domain,
--             DocumentID,
--             RevisionItemNo,
--             FileRef
--         FROM
--             dbo.atbl_DCS_RevisionsFiles with (nolock)
--         WHERE
--             Domain = 'PRO'
--         GROUP BY
--             Domain,
--             DocumentID,
--             RevisionItemNo,
--             FileRef
--         HAVING
--             COUNT(*) > 1
--     ) dup ON RF.FileRef = dup.FileRef
-- WHERE
--     RF.Domain = 'PRO'
-- ORDER BY
--     RF.Domain,
--     RF.DocumentID,
--     RF.RevisionItemNo,
--     RF.FileRef,
--     RF.Created

/*
 * Duplicates
 */
-- SELECT
--     activate_link_document = '<a href="' + '/dcs-documents-details?Domain=' + RF.Domain + '&DocID=' + RF.DocumentID + '">' + RF.DocumentID + '</a>',
--     RF.PrimKey,
--     RF.FileRef
-- FROM
--     dbo.atbl_DCS_RevisionsFiles RF
-- with
--     (nolock)
--     INNER JOIN (
--         SELECT
--             FileRef
--         FROM
--             dbo.atbl_DCS_RevisionsFiles
--         with
--             (nolock)
--         WHERE
--             Domain = 'PRO'
--         GROUP BY
--             FileRef
--         HAVING
--             COUNT(*) > 1
--     ) dup ON RF.FileRef = dup.FileRef
-- WHERE
--     RF.Domain = 'PRO'
-- ORDER BY
--     RF.FileRef,
--     RF.PrimKey
