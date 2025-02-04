/*
 * Follow up local large file transfer
 */
declare @FilesToDownload table
(
    Guid nchar(36)
)

insert into @FilesToDownload
values
('1f250e1f-6e1c-4b7d-9ca9-4312901a2d3c')

select
    RF.object_guid,
    SF.PrimKey
FROM
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RF WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
        ON F.object_guid = RF.object_guid
    LEFT JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
        ON SF.PrimKey = F.FileRef
WHERE
    RF.object_guid in (select * from @FilesToDownload)
