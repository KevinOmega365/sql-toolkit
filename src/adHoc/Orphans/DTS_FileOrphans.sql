SELECT
    Count = COUNT(*)
FROM
    dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
    INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
        ON DR.Domain = DRF.Domain
        AND DR.DocumentID = DRF.DocumentID
        AND DR.RevisionItemNo = DRF.RevisionItemNo
    INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
        ON DRF_SF.PrimKey = DRF.FileRef
WHERE
    NOT EXISTS (
        SELECT *
        FROM
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RF WITH (NOLOCK)
            INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
                ON F.object_guid = RF.object_guid
            INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
                ON SF.PrimKey = F.FileRef
        WHERE
            DRF.Domain = RF.DCS_Domain
            AND DRF.DocumentID = RF.DCS_DocumentID
            AND DR.Revision = RF.Revision
            AND (
                DRF_SF.CRC = SF.CRC
                OR DRF.Import_ExternalUniqueRef = RF.DCS_Import_ExternalUniqueRef
                OR DRF.FileRef = F.FileRef
            )
    )
    AND DRF.Domain = '145'
    AND DRF.CreatedBy = 'af_Integrations_ServiceUser'