declare @ErrorPattern nvarchar(max) = '%UI_atbl_DCS_RevisionsFiles_UniqueFileName%' -- '%FAILED%' -- '%FAILED%Closed review exists%'

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef uniqueidentifier = @Yggdrasil

/*
 * File Comparison - Import vs Pims
 */
select
    Domain = DCS_Domain,
    DocumentID = DCS_DocumentID,
    Revision = DCS_Revision,
    Step = (
        select Step
        from dbo.atbl_DCS_Revisions DcsR with (nolock)
        where 
            DcsR.Domain = RF.DCS_Domain
            and DcsR.DocumentID = RF.DCS_DocumentID
            and DcsR.Revision = RF.DCS_Revision

    ),
    CurrentDCSRevision = (
        select CurrentRevision
        from dbo.atbl_DCS_Documents DcsD with (nolock)
        where
            DcsD.Domain = RF.DCS_Domain
            and DcsD.DocumentID = RF.DCS_DocumentID
    ),
    RevisionItemNo = DCS_RevisionItemNo,
    OriginalFileName = DCS_OriginalFileName,
    FileName = DCS_FileName,
    FileSize = DCS_FileSize,
    PimFileSise = DcsRF.FileSize,
    FileRef = DCS_FileRef,
    object_guid,
    filePurpose,
    DCS_Type,
    fileType,
    md5hash,
    ImportHash = (select CRC from dbo.stbl_System_Files F with (nolock) where F.PrimKey = RF.DCS_FileRef),
    DcsHash = (select CRC from dbo.stbl_System_Files F with (nolock) where F.PrimKey = DcsRF.FileRef),
    HashDiff = abs(abs((select CRC from dbo.stbl_System_Files F with (nolock) where F.PrimKey = RF.DCS_FileRef)) - abs((select CRC from dbo.stbl_System_Files F with (nolock) where F.PrimKey = DcsRF.FileRef))),
    ImportFileSize = DCS_FileSize,
    DcsFileSize = DcsRF.FileSize,
    DcsCreatedBy = DcsRF.CreatedBy,
    OriginalFileCreated = (select Created from dbo.stbl_System_Files as F with (nolock) where F.PrimKey = RF.DCS_FileRef),
    DcsFileRef = DcsRF.FileRef,
    ImportFileRef = DCS_FileRef,
    INTEGR_REC_ERROR
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
    join dbo.atbl_DCS_RevisionsFiles DcsRF with (nolock)
        on DcsRF.Domain = RF.DCS_Domain
        and DcsRF.DocumentID = RF.DCS_DocumentID
        and DcsRF.RevisionItemNo = RF.DCS_RevisionItemNo
        and DcsRF.OriginalFileName = RF.DCS_OriginalFileName
where
    INTEGR_REC_ERROR like @ErrorPattern
    and INTEGR_REC_GROUPREF =  @GroupRef
order by
    DCS_Domain,
    DCS_DocumentID,
    DCS_Revision
