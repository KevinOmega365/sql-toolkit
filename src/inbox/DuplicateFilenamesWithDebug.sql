
-- todo: track down double counting

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
            -- unique columns for DCS revision-files: { Domain, DocumentID, FileName, RevisionItemNo, Type }
            on Import_RF.DCS_Domain = Pims_RF.Domain
            and Import_RF.DCS_DocumentID = Pims_RF.DocumentID
            and Import_RF.DCS_FileName = Pims_RF.FileName
            and Import_RF.DCS_RevisionItemNo = Pims_RF.RevisionItemNo
            and Import_RF.DCS_Type = Pims_RF.Type
        join dbo.stbl_System_Files Import_F with (nolock)
            on Import_F.PrimKey = Import_RF.DCS_FileRef
)


select
    FixedFilename = case
        when InstanceNumber > 1
        then 
            CONCAT(
                SUBSTRING(DCS_FileName, 1, LEN(DCS_FileName) - CHARINDEX('.', REVERSE(DCS_FileName))),
                ' (' + cast(InstanceNumber - 1 as nvarchar(max)) + ')',
                SUBSTRING(DCS_FileName, LEN(DCS_FileName) - CHARINDEX('.', REVERSE(DCS_FileName)) + 1, LEN(DCS_FileName))
            )
        else
            DCS_FileName
    end,
    InstanceNumber,
    Note,
    Action,
    SysFileLinkComparison,

    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_FileName,
    DCS_Type,
    RevisionFileRef,
    FileCreated,
    FileRef,

    PimsRevisionFileRef,
    ImportRevisionFileRef,
    PimsFileCreated,
    ImportFileCreated,
    PimsFileRef,
    ImportFileRef,
    PimsF_CRC,
    ImportF_CRC,
    PimsRF_Import_ExternalUniqueRef,
    ImportRF_DCS_Import_ExternalUniqueRef
from
(
    select
        InstanceNumber = row_number() over(
            partition by
                DCS_Domain,
                DCS_DocumentID,
                DCS_RevisionItemNo,
                DCS_FileName,
                DCS_Type
            order by
                FileCreated,
                FileRef -- I would have hoped that FileCreated would be sufficient
        ),
        Note,
        Action,
        SysFileLinkComparison,
        DCS_Domain,
        DCS_DocumentID,
        DCS_RevisionItemNo,
        DCS_FileName,
        DCS_Type,
        RevisionFileRef,
        FileCreated,
        FileRef,
        PimsRevisionFileRef,
        PimsFileCreated,
        PimsFileRef,
        PimsF_CRC,
        PimsRF_Import_ExternalUniqueRef,
        ImportRevisionFileRef,
        ImportFileCreated,
        ImportFileRef,
        ImportF_CRC,
        ImportRF_DCS_Import_ExternalUniqueRef
    from
    (

            select
                Note = 'Import file with name duplicate im Pims and different content',
                Action = 'Insert into Pims',
                SysFileLinkComparison = case when PimsFileRef = ImportFileRef then 'matched' else 'different' end,
                DCS_Domain,
                DCS_DocumentID,
                DCS_RevisionItemNo,
                DCS_FileName,
                DCS_Type,
                RevisionFileRef = ImportRevisionFileRef,
                FileCreated = ImportFileCreated,
                FileRef = ImportFileRef,
                PimsRevisionFileRef,
                PimsFileCreated,
                PimsFileRef,
                PimsF_CRC,
                PimsRF_Import_ExternalUniqueRef,
                ImportRevisionFileRef,
                ImportFileCreated,
                ImportFileRef,
                ImportF_CRC,
                ImportRF_DCS_Import_ExternalUniqueRef
            from 
                DuplicatedFilenames
            where
                PimsF_CRC != ImportF_CRC
                and PimsRF_Import_ExternalUniqueRef != ImportRF_DCS_Import_ExternalUniqueRef

        union

            select
                Note = 'Pims file with name duplicate in import and different content',
                Action = 'No action: Existing Pims File',
                SysFileLinkComparison = case when PimsFileRef = ImportFileRef then 'matched' else 'different' end,
                DCS_Domain,
                DCS_DocumentID,
                DCS_RevisionItemNo,
                DCS_FileName,
                DCS_Type,
                RevisionFileRef = PimsRevisionFileRef,
                FileCreated = PimsFileCreated,
                FileRef = PimsFileRef,
                PimsRevisionFileRef,
                PimsFileCreated,
                PimsFileRef,
                PimsF_CRC,
                PimsRF_Import_ExternalUniqueRef,
                ImportRevisionFileRef,
                ImportFileCreated,
                ImportFileRef,
                ImportF_CRC,
                ImportRF_DCS_Import_ExternalUniqueRef
            from 
                DuplicatedFilenames
            where
                PimsF_CRC != ImportF_CRC
                and PimsRF_Import_ExternalUniqueRef != ImportRF_DCS_Import_ExternalUniqueRef

        /**
        * although slower, there are small number of duplicated values where the
        * import unique id differ, but refer to the same revision-file im Pims,
        * these should not be douple counted when determining the filename suffix
        */
        union

            select
                Note = 'Same file name, same comtent or external ID',
                Action = 'No action: Existing Pims File',
                SysFileLinkComparison = case when PimsFileRef = ImportFileRef then 'matched' else 'different' end,
                DCS_Domain,
                DCS_DocumentID,
                DCS_RevisionItemNo,
                DCS_FileName,
                DCS_Type,
                RevisionFileRef = PimsRevisionFileRef,
                FileCreated = PimsFileCreated,
                FileRef = PimsFileRef,
                PimsRevisionFileRef,
                PimsFileCreated,
                PimsFileRef,
                PimsF_CRC,
                PimsRF_Import_ExternalUniqueRef,
                ImportRevisionFileRef,
                ImportFileCreated,
                ImportFileRef,
                ImportF_CRC,
                ImportRF_DCS_Import_ExternalUniqueRef
            from 
                DuplicatedFilenames
            where
                PimsF_CRC = ImportF_CRC
                or PimsRF_Import_ExternalUniqueRef = ImportRF_DCS_Import_ExternalUniqueRef

    ) T

) U

order by
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_FileName,
    DCS_Type,
    InstanceNumber desc