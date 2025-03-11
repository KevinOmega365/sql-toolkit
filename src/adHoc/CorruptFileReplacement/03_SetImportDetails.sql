update FRR set
    DCS_Domain = I_RF.DCS_Domain,
    DCS_DocumentID = I_RF.DCS_DocumentID,
    DCS_RevisionItemNo = I_RF.DCS_RevisionItemNo,
    DCS_FileName = I_RF.DCS_FileName,
    DCS_FileRef = I_RF.DCS_FileRef,
    DCS_Type = I_RF.DCS_Type,
    DCS_FileSize = I_RF.DCS_FileSize,
    DCS_SortOrder = I_RF.DCS_SortOrder,
    DCS_OriginalFileName = I_RF.DCS_OriginalFileName,
    DCS_Import_ExternalUniqueRef = I_RF.DCS_Import_ExternalUniqueRef,
    DCS_FileDescription = I_RF.DCS_FileDescription
from
    dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
    join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I_RF with (nolock)
        on I_RF.object_guid = FRR.object_guid