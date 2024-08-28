/*
 * Add a system file into DTS-DCS files
 */

declare @FileImportDetails nvarchar(max) =
'{
    "md5hash":"7AA8F5DE372B6568C6D2ECFD1E302366",
    "object_guid":"e5350cc4-de3b-409e-bcf5-2241ae9b1432",
    "originalFilename":"UPP-AIL-N-VA-00003_08_1.PDF"
}'

declare @FileRef uniqueidentifier = '6FBBA035-1EE3-4763-8DC0-0E017E1DA666'

declare @PipelineRef uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2'

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
select
    originalFilename = json_value(@FileImportDetails, '$.originalFilename'),
    object_guid = json_value(@FileImportDetails, '$.object_guid'),
    md5hash = json_value(@FileImportDetails, '$.md5hash'),
    INTEGR_REC_GROUPREF = @PipelineRef,
    INTEGR_REC_BATCHREF = newid(),
    FileUpdated = getdate(),
    FileSize,
    FileRef = Primkey,
    FileName
from
    dbo.stbl_System_Files with (nolock)
where
    PrimKey = @FileRef

