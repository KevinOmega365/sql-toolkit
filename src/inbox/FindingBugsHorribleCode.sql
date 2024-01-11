/**
 *  all of the files in the import and
    all of the files in Pims
    and don't "double count" the files that have the same checksum
 */


-- all of the files in the import that are not in pims

-- all of the files that are in Pims but not in the import

-- all of the files that are in both

select
    FixedFilename = case
        when RowNumber > 1
        then 
            CONCAT(
                SUBSTRING(Filename, 1, LEN(Filename) - CHARINDEX('.', REVERSE(Filename))),
                ' (' + cast(RowNumber - 1 as nvarchar(max)) + ')',
                SUBSTRING(Filename, LEN(Filename) - CHARINDEX('.', REVERSE(Filename)) + 1, LEN(Filename))
            )
        else
            Filename
    end
    , *
from
    (
        select
                Domain = coalesce(Import.DCS_Domain, Pims.Domain),
                DocumentID = coalesce(Import.DCS_DocumentID, Pims.DocumentID),
                RevisionItemNo = coalesce(Import.DCS_RevisionItemNo, Pims.RevisionItemNo),
                RowNumber = row_number() over(
                    partition by
                        coalesce(Import.DCS_Domain, Pims.Domain),
                        coalesce(Import.DCS_DocumentID, Pims.DocumentID),
                        coalesce(Import.DCS_RevisionItemNo, Pims.RevisionItemNo),
                        coalesce(Import.DCS_Filename, Pims.Filename)
                    order by
                        coalesce(Import.Created, Pims.Created)
                ),
                Filename = coalesce(Import.DCS_Filename, Pims.Filename),
                FileRef = coalesce(Import.DCS_FileRef, Pims.FileRef),
                Created = coalesce(Import.Created, Pims.Created),
                Location = isnull(Import.Source, '') + isnull(Pims.Source, ''),
                ImportStatus = isnull(Import.INTEGR_REC_STATUS, ''),
                PrimKey = coalesce(Import.PrimKey, Pims.PrimKey),
                DownloadedFilePrimKey,
                DownloadedFileSysRef,
                SystemCheckSum
        from
            (
                select
                    Source = 'Pims',
                    F.Domain,
                    F.DocumentID,
                    F.RevisionItemNo,
                    F.Filename,
                    F.FileRef,
                    SF.CRC,
                    F.Import_ExternalUniqueRef,
                    F.Created,
                    F.CreatedBy,
                    ImportStatus = '',
                    ErrorText = '',
                    F.PrimKey
                from
                    dbo.atbl_DCS_RevisionsFiles F with (nolock) 
                    inner join dbo.stbl_System_Files AS SF with (nolock)
                        on SF.PrimKey = F.FileRef
            ) Pims
            full outer join (
                select
                    Source = 'Import',
                    RF.DCS_Domain,
                    RF.DCS_DocumentID,
                    RF.DCS_RevisionItemNo,
                    RF.DCS_Filename,
                    RF.DCS_FileRef,
                    SF.CRC,
                    RF.DCS_Import_ExternalUniqueRef,
                    F.Created, -- Files are persistent
                    F.CreatedBy,
                    RF.INTEGR_REC_STATUS,
                    RF.INTEGR_REC_ERROR,
                    DownloadedFilePrimKey = F.PrimKey,
                    DownloadedFileSysRef = F.FileRef,
                    SystemCheckSum = SF.CRC,
                    RF.PrimKey
                from
                    dbo.ltbl_Import_MuninAibel_RevisionFiles RF with (nolock)
                    join dbo.ltbl_Import_MuninAibel_Files as F with (nolock)
                        on F._md5Hash = RF._md5Hash
                    inner join dbo.stbl_System_Files AS SF with (nolock)
                        on SF.PrimKey = F.FileRef
            ) Import
                on Import.DCS_Domain = Pims.Domain
                and Import.DCS_DocumentID = Pims.DocumentID
                and Import.DCS_RevisionItemNo = Pims.RevisionItemNo
                and Import.DCS_FileRef = Pims.FileRef

        where
            DocumentID = 'DN02-4500318888-R-DS-0002' and RevisionItemNo = 1
            or DocumentID = 'DN02-4500318888-R-DS-0002' and RevisionItemNo = 1
            or DocumentID = 'DN02-AI-P-DS-0100' and RevisionItemNo = 5
            or DocumentID = 'DN02-AI-P-DS-0241' and RevisionItemNo = 2

            or DCS_DocumentID = 'DN02-4500318888-R-DS-0002' and DCS_RevisionItemNo = 1
            or DCS_DocumentID = 'DN02-4500318888-R-DS-0002' and DCS_RevisionItemNo = 1
            or DCS_DocumentID = 'DN02-AI-P-DS-0100' and DCS_RevisionItemNo = 5
            or DCS_DocumentID = 'DN02-AI-P-DS-0241' and DCS_RevisionItemNo = 2
    ) T
order by
    Domain,
    DocumentID,
    RevisionItemNo,
    RowNumber,
    Filename
