declare @groupRef uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

/*
 * missing 
 */
select distinct
    R.DCS_Domain,
    R.DCS_DocumentID,
    R.DCS_Revision,
    FileMetadata =
        case
            when RF.PrimKey is null
            then 'nope'
            else 'yupp'
        end,
    FileDownload =
        case
            when F.PrimKey is null
            then 'nope'
            else 'yupp'
        end,
    FileStorage =
        case
            when SF.PrimKey is null
            then 'nope'
            else 'yupp'
        end
from
    dbo.ltbl_Import_DTS_DCS_Revisions R with (nolock)
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
        on RF.DCS_Domain = R.DCS_Domain
        and RF.DCS_DocumentID = R.DCS_DocumentID
        and RF.DCS_Revision = R.DCS_Revision
    left join dbo.ltbl_Import_DTS_DCS_Files as F with (nolock)
        on F.object_guid = RF.object_guid
    left join dbo.stbl_System_Files as SF with (nolock)
        on SF.PrimKey = F.FileRef
where
    R.INTEGR_REC_ERROR = 'Quallity Failure: Revision without Files'
    and R.INTEGR_REC_GROUPREF = @groupRef
order by
    R.DCS_Domain,
    R.DCS_DocumentID,
    R.DCS_Revision
