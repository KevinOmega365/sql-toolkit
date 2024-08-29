declare @FileRef uniqueidentifier = '6FBBA035-1EE3-4763-8DC0-0E017E1DA666'
declare @RevisionFileRef uniqueidentifier = 'c6d260b4-e6ac-4311-a96b-fbdc148af9fd'

-- insert into dbo.ltbl_Import_DTS_DCS_Files (
--     originalFilename,
--     object_guid,
--     md5hash,
--     INTEGR_REC_GROUPREF,
--     INTEGR_REC_BATCHREF,
--     FileUpdated,
--     FileSize,
--     FileRef,
--     FileName
-- )
select top 1  -- really not needed, but cross joins can go badly
    originalFilename = SystemFiles.FileName,
    RevisionsFiles.object_guid,
    RevisionsFiles.md5hash,
    RevisionsFiles.INTEGR_REC_GROUPREF,
    RevisionsFiles.INTEGR_REC_BATCHREF,
    FileUpdated = getdate(),
    SystemFiles.FileSize,
    FileRef = SystemFiles.Primkey,
    SystemFiles.FileName
from
    dbo.stbl_System_Files SystemFiles with (nolock),
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles RevisionsFiles with (nolock)
where
    SystemFiles.PrimKey = @FileRef
    and RevisionsFiles.PrimKey = @RevisionFileRef
