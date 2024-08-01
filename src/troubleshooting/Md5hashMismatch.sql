/*
 * checking md5hash vs guid
 */
-- select
--     R.DCS_Domain,
--     R.DCS_DocumentID,
--     R.DCS_Revision,

--     -- RevisionStatus = R.INTEGR_REC_STATUS,
--     -- RevisionError = R.INTEGR_REC_ERROR,
--     -- RF.object_guid,
--     -- RF.fileType,
--     -- RF.fileComment,
--     -- RF.DCS_FileName,

--     -- md5Hash = F.md5Hash,
--     -- md5Hash = RF.md5Hash,
--     md5Hash = case
--         when F.md5Hash is null or RF.md5Hash is null
--         then null
--         else
--             case
--                 when F.md5Hash = RF.md5Hash
--                 then 'yupp'
--                 else 'nope'
--             end
--         end,
--     -- F.FileRef,
--     -- RF.DCS_FileRef,
--     FileRef = case
--         when F.FileRef is null or RF.DCS_FileRef is null
--         then null
--         else
--             case
--                 when F.FileRef = RF.DCS_FileRef
--                 then 'yupp'
--                 else 'nope'
--             end
--         end,

--     FileStatus = RF.INTEGR_REC_STATUS,
--     -- FileError = RF.INTEGR_REC_ERROR,
--     FileTrace = RF.INTEGR_REC_TRACE,
--     -- FilesJson = RF.JsonRow,

--     -- F.FileSize,
--     -- RF.FileSize,
--     -- SizeDiff = RF.FileSize - F.FileSize,
--     -- SizeDiffPercent = format(abs(1.0 * (RF.FileSize - F.FileSize) / (RF.FileSize + F.FileSize)), 'P3')

--     SF.PrimKey
-- from
--     dbo.ltbl_Import_DTS_DCS_Revisions R with (nolock)
--     left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
--         on RF.DCS_Domain = R.DCS_Domain
--         and RF.DCS_DocumentID = R.DCS_DocumentID
--         and RF.DCS_Revision = R.DCS_Revision
--     left join dbo.ltbl_Import_DTS_DCS_Files as F with (nolock)
--         on F.object_guid = RF.object_guid
--     left join dbo.stbl_System_Files as SF with (nolock)
--         on SF.PrimKey = F.FileRef
-- where
--     R.INTEGR_REC_ERROR = 'Quallity Failure: Revision without Files'
--     and R.INTEGR_REC_GROUPREF = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
-- order by
--     R.DCS_Domain,
--     R.DCS_DocumentID,
--     R.DCS_Revision