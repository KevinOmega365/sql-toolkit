
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

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #RevisionsFilesLinks
CREATE TABLE #RevisionsFilesLinks (
    PimsRef UNIQUEIDENTIFIER,
    ImportRef UNIQUEIDENTIFIER
)
INSERT INTO
    #RevisionsFilesLinks (PimsRef, ImportRef)
SELECT
    P.PrimKey AS PimsRef,
    I.PrimKey AS ImportRef
FROM
    (
        SELECT
            DRF.PrimKey,
            DRF.Domain,
            DRF.DocumentID,
            DR.Revision,
            DRF.Import_ExternalUniqueRef,
            DRF.FileRef,
            DRF_SF.CRC
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
                ON DR.Domain = DRF.Domain
                AND DR.DocumentID = DRF.DocumentID
                AND DR.RevisionItemNo = DRF.RevisionItemNo
            INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
                ON DRF_SF.PrimKey = DRF.FileRef
        WHERE
            DRF.Domain IN (select DCS_Domain from @DomainList)
    ) P
    JOIN (
        SELECT
            RF.PrimKey,
            RF.DCS_Domain,
            RF.DCS_DocumentID,
            RF.DCS_Revision,
            RF.DCS_Import_ExternalUniqueRef,
            RF.DCS_FileRef,
            SF.CRC
        FROM
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RF WITH (NOLOCK)
            INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
                ON SF.PrimKey = RF.DCS_FileRef
        WHERE
            RF.DCS_Domain IN (select DCS_Domain from @DomainList)
    ) I
        ON P.Domain = I.DCS_Domain
        AND P.DocumentID = I.DCS_DocumentID
        AND P.Revision = I.DCS_Revision
        AND (
            I.CRC = P.CRC
            OR I.DCS_Import_ExternalUniqueRef = P.Import_ExternalUniqueRef
            OR I.DCS_FileRef = P.FileRef
        )
        
CREATE NONCLUSTERED INDEX ix_PimsImport ON #RevisionsFilesLinks (PimsRef, ImportRef);

CREATE NONCLUSTERED INDEX ix_ImportPims ON #RevisionsFilesLinks (ImportRef, PimsRef);

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

/*
 * Count of documents and files with orphaned files on current revisions
 */
-- SELECT
--     DRF.Domain,
--     AffectedDocuments = COUNT(DISTINCT DRF.DocumentID),
--     COUNT(*) AS OrphanedFiles
-- FROM
--     dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
--     JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
--         ON DR.Domain = DRF.Domain
--         AND DR.DocumentID = DRF.DocumentID
--         AND DR.RevisionItemNo = DRF.RevisionItemNo
--     JOIN dbo.atbl_DCS_Documents AS DD WITH (NOLOCK)
--         ON DD.Domain = DRF.Domain
--         AND DD.DocumentID = DRF.DocumentID
--         AND DD.CurrentRevisionItemNo = DRF.RevisionItemNo
--     LEFT JOIN #RevisionsFilesLinks L
--         ON DRF.PrimKey = L.PimsRef
-- WHERE
--     DRF.CreatedBy = 'af_Integrations_ServiceUser'
--     AND L.ImportRef IS NULL
--     AND DRF.Domain IN (select DCS_Domain from @DomainList)
-- GROUP BY
--     DRF.Domain
-- ORDER BY
--     DRF.Domain

/*
 * Orphaned files from current revisions
 */
SELECT
    DRF.Domain,
    DRF.DocumentID,
    DD.CurrentRevision,
    Type,
    -- FileDescription,
    FileName,
    OriginalFileName
    , URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open "&B2)'
FROM
    dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
    JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
        ON DR.Domain = DRF.Domain
        AND DR.DocumentID = DRF.DocumentID
        AND DR.RevisionItemNo = DRF.RevisionItemNo
    JOIN dbo.atbl_DCS_Documents AS DD WITH (NOLOCK)
        ON DD.Domain = DRF.Domain
        AND DD.DocumentID = DRF.DocumentID
        AND DD.CurrentRevisionItemNo = DRF.RevisionItemNo
    LEFT JOIN #RevisionsFilesLinks L
        ON DRF.PrimKey = L.PimsRef
WHERE
    DRF.CreatedBy = 'af_Integrations_ServiceUser'
    AND L.ImportRef IS NULL
    AND DRF.Domain IN (select DCS_Domain from @DomainList)
ORDER BY
    DRF.Domain,
    DRF.DocumentID,
    DD.CurrentRevision,
    Type,
    -- FileDescription,
    FileName
