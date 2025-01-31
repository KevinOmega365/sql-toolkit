declare
    @FileObjectGuid nchar(36) = 'OBJECT_GUID_FROM_DASHBOARD_AND_POSTMAN',
    @DevToolsFilesFileRef uniqueidentifier = 'FILEREF_FROM_INTEGRATIONS_DEVTOOLS'

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
    originalFilename = DevToolsFiles.FileName,
    RevisionsFiles.object_guid,
    RevisionsFiles.md5hash,
    RevisionsFiles.INTEGR_REC_GROUPREF,
    RevisionsFiles.INTEGR_REC_BATCHREF,
    FileUpdated = getdate(),
    DevToolsFiles.FileSize,
    DevToolsFiles.FileRef,
    DevToolsFiles.FileName
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles RevisionsFiles with (nolock)
    cross join dbo.atbl_Integrations_DevTools_FileTable DevToolsFiles with (nolock)
 where
    RevisionsFiles.object_guid = @FileObjectGuid
    and DevToolsFiles.FileRef = @DevToolsFilesFileRef
