declare @PipelineGroupRefMappingJson nvarchar(max) = '[
    {
        "PrimKey": "F6C3687C-5511-48F2-98E5-8E84EEE9B689",
        "MapTo": "83EF485B-914A-4AE1-8DF0-A09D754423C0"
    },
    {
        "PrimKey": "E1A66F7C-AB9B-4586-AA71-4B4CAB743AA2",
        "MapTo": "8EA7D4C2-2A58-4DCB-ADA1-840473BE2592"
    },
    {
        "PrimKey": "564D970E-8B1A-4A4A-913B-51E44D4BD8E7",
        "MapTo": "E1CB75A4-FD5B-405C-8885-F64BBB3B09FF"
    },
    {
        "PrimKey": "EFD3449E-3A44-4C38-B0E7-F57CA48CF8B0",
        "MapTo": "90B176F8-7B12-4C70-9027-7FAA71EEA975"
    },
    {
        "PrimKey": "EDADD424-81CE-4170-B419-12642F80CFDE",
        "MapTo": "85CC62A6-FF55-4940-88FC-62AF58F36F68"
    }
]'

-- select *
-- from openjson(@PipelineGroupRefMappingJson)
-- with (
--     Name nvarchar(128),
--     PrimKey uniqueidentifier,
--     MapTo uniqueidentifier
-- )

select
    DocumentsUpdateStatement = 'update dbo.ltbl_Import_DTS_DCS_Documents set INTEGR_REC_GROUPREF = ''' + cast(MapTo as nchar(36)) + ''' where INTEGR_REC_GROUPREF = ''' + cast(PrimKey as nchar(36)) + '''',
    RevisionsUpdateStatement = 'update dbo.ltbl_Import_DTS_DCS_Revisions set INTEGR_REC_GROUPREF = ''' + cast(MapTo as nchar(36)) + ''' where INTEGR_REC_GROUPREF = ''' + cast(PrimKey as nchar(36)) + '''',
    RevisionsFilesUpdateStatement = 'update dbo.ltbl_Import_DTS_DCS_RevisionsFiles set INTEGR_REC_GROUPREF = ''' + cast(MapTo as nchar(36)) + ''' where INTEGR_REC_GROUPREF = ''' + cast(PrimKey as nchar(36)) + ''''
from
    openjson(@PipelineGroupRefMappingJson)
    with (
        Name nvarchar(128),
        PrimKey uniqueidentifier,
        MapTo uniqueidentifier
    )

-- SELECT
--     Name,
--     PrimKey,
--     MapTo = NEWID()
-- FROM
--     dbo.atbl_Integrations_ScheduledTasksConfigGroups WITH (NOLOCK)
-- WHERE
--     PrimKey IN (
--         'f6c3687c-5511-48f2-98e5-8e84eee9b689',
--         'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
--         '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
--         'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
--         'edadd424-81ce-4170-b419-12642f80cfde'
--     )
-- ORDER BY
--     Name
-- FOR JSON AUTO