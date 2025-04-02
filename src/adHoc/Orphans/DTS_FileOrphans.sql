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
            DRF.Domain IN ('128', '145', '153', '187')
            AND DRF.CreatedBy = 'af_Integrations_ServiceUser'
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
            RF.DCS_Domain IN ('128', '145', '153', '187')
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

SELECT
    T.Domain,
    CommonRevisionFiles,
    OrphanedFiles,
    IgnoredFiles
FROM
    (
        SELECT
            Domain,
            COUNT(*) AS CommonRevisionFiles
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            JOIN #RevisionsFilesLinks L
                ON DRF.PrimKey = L.PimsRef
        WHERE
            DRF.Domain IN ('128', '145', '153', '187')
        GROUP BY
            Domain
    ) T
    JOIN (
        SELECT
            Domain,
            COUNT(*) AS OrphanedFiles
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            LEFT JOIN #RevisionsFilesLinks L
                ON DRF.PrimKey = L.PimsRef
        WHERE
            DRF.CreatedBy = 'af_Integrations_ServiceUser'
            AND L.ImportRef IS NULL
            AND DRF.Domain IN ('128', '145', '153', '187')
        GROUP BY
            Domain
    ) U ON U.Domain = T.Domain
    JOIN (
        SELECT
            Domain = I.DCS_Domain,
            COUNT(*) AS IgnoredFiles
        FROM
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
            LEFT JOIN #RevisionsFilesLinks L
                ON I.PrimKey = L.ImportRef
        WHERE
            L.PimsRef IS NULL
            AND I.DCS_Domain IN ('128', '145', '153', '187')
        GROUP BY
            I.DCS_Domain
    ) V ON V.Domain = U.Domain
