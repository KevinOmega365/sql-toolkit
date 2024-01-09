select
    DCS_Filename,
    DisambiguatedFilename =
        case
            when RowNumber > 1
            then DCS_Filename + ' (' + cast((RowNumber - 1) as nvarchar(max)) + ')'
            else DCS_Filename
        end,
    FileDownloadDate
from
    (
        select
            --DCS_DocumentID,
            --DCS_Domain,
            RF.DCS_FileName,
            RowNumber = row_number() over(
                partition by
                    RF.DCS_DocumentID,
                    RF.DCS_Domain,
                    RF.DCS_FileName,
                    RF.DCS_RevisionItemNo,
                    RF.DCS_Type
                order by
                    F.Created
            ),
            FileDownloadDate = F.Created
            --DCS_RevisionItemNo,
            --DCS_Type
        from
            dbo.ltbl_Import_MuninAibel_RevisionFiles AS RF WITH (NOLOCK)
            INNER JOIN dbo.ltbl_Import_MuninAibel_Files AS F WITH (NOLOCK)
                ON F._md5Hash = RF._md5Hash
            INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
                ON SF.PrimKey = F.FileRef
        where
            exists (
                select null -- can't use '*' with grouped data
                FROM
                    dbo.ltbl_Import_MuninAibel_RevisionFiles AS DuplicatedFilenames WITH (NOLOCK)
                where
                    DuplicatedFilenames.DCS_DocumentID = RF.DCS_DocumentID
                    and DuplicatedFilenames.DCS_Domain = RF.DCS_Domain
                    and DuplicatedFilenames.DCS_FileName = RF.DCS_FileName
                    and DuplicatedFilenames.DCS_RevisionItemNo = RF.DCS_RevisionItemNo
                    and DuplicatedFilenames.DCS_Type = RF.DCS_Type
                group by -- constraining columns from UI_atbl_DCS_RevisionsFiles_UniqueFileName
                    DCS_DocumentID,
                    DCS_Domain,
                    DCS_FileName,
                    DCS_RevisionItemNo,
                    DCS_Type
                having
                    count(*) > 1
        )
    
    ) T