/*
 * Row counts for all DTS_DCS import tables
 */
select
    BoundaryDrawings = (select count(*) from dbo.ltbl_Import_DTS_DCS_BoundaryDrawings with (nolock)),
    Documents = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)),
    Documents_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents_RAW with (nolock)),
    DocumentsPlan = (select count(*) from dbo.ltbl_Import_DTS_DCS_DocumentsPlan with (nolock)),
    Files = (select count(*) from dbo.ltbl_Import_DTS_DCS_Files with (nolock)),
    ResponseToComments = (select count(*) from dbo.ltbl_Import_DTS_DCS_ResponseToComments with (nolock)),
    Revisions = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)),
    Revisions_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions_RAW with (nolock)),
    RevisionsApprovalTrayItems = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems with (nolock)),
    RevisionsFiles = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)),
    RevisionsFiles_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles_RAW with (nolock)),
    SupplierPoAttachments = (select count(*) from dbo.ltbl_Import_DTS_DCS_SupplierPoAttachments with (nolock))
for json
    path,
    without_array_wrapper

-- select
--     Documents = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents AS [DTS] with (nolock)),
--     Revisions = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions as [DTS] with (nolock) ),
--     RevisionsFiles = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS [DTS] with (nolock))

-- select name from sys.objects where name like 'ltbl_Import_DTS_DCS_%' and type = 'u' order by name
