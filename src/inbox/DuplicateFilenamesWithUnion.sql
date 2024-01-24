
    -- FixedFilename = case
    --     when RowNumber > 1
    --     then 
    --         CONCAT(
    --             SUBSTRING(Filename, 1, LEN(Filename) - CHARINDEX('.', REVERSE(Filename))),
    --             ' (' + cast(RowNumber - 1 as nvarchar(max)) + ')',
    --             SUBSTRING(Filename, LEN(Filename) - CHARINDEX('.', REVERSE(Filename)) + 1, LEN(Filename))
    --         )
    --     else
    --         Filename
    -- end
with DuplicatedFilenames as (
    select
        DCS_Domain,
        DCS_DocumentID,
        DCS_RevisionItemNo,
        DCS_FileName,
        DCS_Type,
        PimsRevisionFileRef = Pims_RF.PrimKey,
        PimsFileCreated = Pims_F.Created,
        PimsFileRef = Pims_F.PrimKey,
        PimsF_CRC = Pims_F.CRC,
        PimsRF_Import_ExternalUniqueRef = Pims_RF.Import_ExternalUniqueRef,
        ImportRevisionFileRef = Import_RF.PrimKey,
        ImportFileCreated = Import_F.Created,
        ImportFileRef = Import_F.PrimKey,
        ImportF_CRC = Import_F.CRC,
        ImportRF_DCS_Import_ExternalUniqueRef = Import_RF.DCS_Import_ExternalUniqueRef
    from
        dbo.atbl_DCS_RevisionsFiles AS Pims_RF WITH (NOLOCK)
        join dbo.stbl_System_Files Pims_F with (nolock)
            on Pims_F.PrimKey = Pims_RF.FileRef
        join dbo.ltbl_Import_MuninAibel_RevisionFiles AS Import_RF WITH (NOLOCK)
            on Import_RF.DCS_Domain = Pims_RF.Domain
            and Import_RF.DCS_DocumentID = Pims_RF.DocumentID
            and Import_RF.DCS_FileName = Pims_RF.FileName
            and Import_RF.DCS_RevisionItemNo = Pims_RF.RevisionItemNo
            and Import_RF.DCS_Type = Pims_RF.Type
        join dbo.stbl_System_Files Import_F with (nolock)
            on Import_F.PrimKey = Import_RF.DCS_FileRef
)


    select
        DCS_Domain,
        DCS_DocumentID,
        DCS_RevisionItemNo,
        DCS_FileName,
        DCS_Type,
        PimsRevisionFileRef,
        PimsFileCreated,
        PimsFileRef,
        ImportRevisionFileRef,
        ImportFileCreated,
        ImportFileRef
    from 
        DuplicatedFilenames
    where
        PimsF_CRC != ImportF_CRC
        and PimsRF_Import_ExternalUniqueRef != ImportRF_DCS_Import_ExternalUniqueRef

union all

    select
        DCS_Domain,
        DCS_DocumentID,
        DCS_RevisionItemNo,
        DCS_FileName,
        DCS_Type,
        PimsRevisionFileRef,
        PimsFileCreated,
        PimsFileRef,
        ImportRevisionFileRef,
        ImportFileCreated,
        ImportFileRef
    from 
        DuplicatedFilenames
    where
        PimsF_CRC = ImportF_CRC
        or PimsRF_Import_ExternalUniqueRef = ImportRF_DCS_Import_ExternalUniqueRef

order by
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_FileName,
    DCS_Type