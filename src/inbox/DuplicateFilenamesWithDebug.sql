
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

select
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_FileName,
    DCS_Type,
    PimsRevisionFileRef = Pims_RF.PrimKey,
    PimsFileCreated = Pims_F.Created,
    PimsFileRef = Pims_F.PrimKey,
    ImportRevisionFileRef = Import_RF.PrimKey,
    ImportFileCreated = Import_F.Created,
    ImportFileRef = Import_F.PrimKey,
    IsMatched =
        case
            when
                Pims_F.CRC = Import_F.CRC
                or Import_ExternalUniqueRef = DCS_Import_ExternalUniqueRef
            then
                'matched'
            else
                ''
        end,
    FileRef =
        case
            when
                Pims_F.PrimKey = Import_F.PrimKey
            then
                'same'
            else
                ''
        end,
    CRC =
        case
            when
                Pims_F.CRC = Import_F.CRC
            then
                'matched'
            else
                ''
        end,
    ExternalRef =
        case
            when
                Pims_RF.Import_ExternalUniqueRef = Import_RF.DCS_Import_ExternalUniqueRef
            then
                'matched'
            else
                ''
        end
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
-- where
--     Pims_F.CRC != Import_F.CRC
--     and Import_ExternalUniqueRef != DCS_Import_ExternalUniqueRef
order by
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_FileName,
    DCS_Type
