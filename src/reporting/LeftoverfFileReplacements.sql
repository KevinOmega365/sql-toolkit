/**
 * Documents to replace
 */

select
    Domain = D.Domain,
    DocumentID = D.DocumentID,
    RevisonAndCurrent = DR.Revision + case when DR.Revision <> D.CurrentRevision then ' ( ' + D.CurrentRevision + ' )' else '' end,
    OriginalFilename = DRF.OriginalFilename,
    StatusComment = case
        when DR.Revision <> D.CurrentRevision then 'file on an older than current revision'
        when I_SF.FileSize is null then 'File does not exist in the imported files'
        when I_SF.FileSize = 0 then 'Imported file has no content'
        else '¯\_(ツ)_/¯'
    end
from
    dbo.atbl_DCS_RevisionsFiles DRF with (nolock)
    join dbo.atbl_DCS_Revisions DR with (nolock)
        on DR.Domain = DRF.Domain
        and DR.DocumentID = DRF.DocumentID
        and DR.RevisionItemNo = DRF.RevisionItemNo
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = DR.Domain
        and D.DocumentID = DR.DocumentID

    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I_RF WITH (NOLOCK)
        on DRF.Domain = I_RF.DCS_Domain
        AND DRF.DocumentID = I_RF.DCS_DocumentID
        AND DR.Revision = I_RF.Revision
        and DRF.OriginalFilename = I_RF.originalFilename
    left JOIN dbo.ltbl_Import_DTS_DCS_Files AS I_F WITH (NOLOCK)
        ON I_F.md5Hash = I_RF.md5Hash
    left JOIN dbo.stbl_System_Files AS I_SF WITH (NOLOCK)
        ON I_SF.PrimKey = I_F.FileRef
where
    D.Domain = '175'
    and DRF.CreatedBy = 'af_Integrations_ServiceUser'
    and (
        DRF.FileSize = 215
        or DRF.FileSize = 0
    )
order by
    Domain,
    DocumentID,
    RevisonAndCurrent,
    OriginalFilename