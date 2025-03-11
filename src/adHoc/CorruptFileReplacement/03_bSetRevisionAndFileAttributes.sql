    UPDATE FRR 
    SET DCS_RevisionItemNo = R.RevisionItemNo
    FROM
        dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
        join dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS IRF WITH (NOLOCK)
            on IRF.object_guid = FRR.object_guid
        INNER JOIN dbo.ltbl_Import_DTS_DCS_Revisions AS IR WITH  (NOLOCK)
            ON IR.DCS_Domain = IRF.DCS_Domain
            AND IR.DCS_DocumentID = IRF.DCS_DocumentID
            AND IR.DCS_Revision = IRF.DCS_Revision
            AND IR.DCS_Revision = IRF.DCS_Revision
        INNER JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = IRF.DCS_Domain
            AND R.DocumentID = IRF.DCS_DocumentID
            AND R.Revision = IRF.DCS_Revision

    -------------------------------------------------------- File Attributes --
    UPDATE FRR
    SET
        DCS_FileName = F.FileName,
        DCS_FileRef = F.FileRef,
        DCS_FileSize = F.FileSize
    FROM
        dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
        join dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RF WITH (NOLOCK)
            on RF.object_guid = FRR.object_guid
        JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
            ON F.object_guid = RF.object_guid
