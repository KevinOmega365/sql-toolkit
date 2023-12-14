
select
    Documents = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)),
    Revisions = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)),
    RevisionsFiles = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock))

select
    RAW_Documents = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents_RAW with (nolock)),
    RAW_Revisions = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions_RAW with (nolock)),
    RAW_RevisionsFiles = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles_RAW with (nolock))
