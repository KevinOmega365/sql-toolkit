/**
 * Files that have been imported and do not already exist in Pims
 */

declare @questionFiles table (
    docNo nvarchar(max),
    rev nvarchar(max),
    filename nvarchar(max)
)
insert into @questionFiles
values
    ('DOCUMENT_ID_HERE','REVISION_HERE','ORIGINAL_FILE_NAME_HERE')
    --, ...

select
    DocumentID = QuestionFiles.docNo,
    Revision = QuestionFiles.rev,
    OriginalFileName = QuestionFiles.filename,
    RF.INTEGR_REC_ERROR
from
    @questionFiles QuestionFiles
    inner join dbo.ltbl_Import_MuninAibel_RevisionFiles AS RF WITH (NOLOCK)
        on RF.DCS_DocumentID = QuestionFiles.docNo
        and RF.DCS_Revision = QuestionFiles.rev
        and RF.DCS_OriginalFileName = QuestionFiles.filename
    INNER JOIN dbo.ltbl_Import_MuninAibel_Files AS F WITH (NOLOCK)
        ON F._md5Hash = RF._md5Hash
    INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
        ON SF.PrimKey = F.FileRef
WHERE
    NOT EXISTS (
        SELECT *
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
                ON DR.Domain = DRF.Domain
                AND DR.DocumentID = DRF.DocumentID
                AND DR.RevisionItemNo = DRF.RevisionItemNo
            INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
                ON DRF_SF.PrimKey = DRF.FileRef
        WHERE
            DRF.Domain = RF.DCS_Domain
            AND DRF.DocumentID = RF.DCS_DocumentID
            AND DR.Revision = RF.Revision
            AND (
                DRF_SF.CRC = SF.CRC
                OR DRF.Import_ExternalUniqueRef = RF.DCS_Import_ExternalUniqueRef
            )
    )
