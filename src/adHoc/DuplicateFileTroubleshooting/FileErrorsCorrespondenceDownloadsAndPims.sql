
declare @ErrorPattern nvarchar(max) = '%FAILED%' -- '%FAILED%Closed review exists%'

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef uniqueidentifier = @Yggdrasil

/*
 * Count
 */
-- select count(*) as Count
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
-- where
--     INTEGR_REC_ERROR like @ErrorPattern
--     and INTEGR_REC_GROUPREF =  @GroupRef

/*
 * Count by Error
 */
-- select
--     INTEGR_REC_ERROR as Error,
--     count(*) as Count
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
-- where
--     INTEGR_REC_ERROR like @ErrorPattern
--     and INTEGR_REC_GROUPREF =  @GroupRef
-- group by
--     INTEGR_REC_ERROR

/*
 * Detail
 */
-- select *
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
-- where
--     INTEGR_REC_ERROR like @ErrorPattern
--     and INTEGR_REC_GROUPREF =  @GroupRef

/*
 * Looking for existing files in downloads and Pims
 */
select
    Domain = DCS_Domain,
    DocumentID = DCS_DocumentID,
    Revision = DCS_Revision,
    RevisionItemNo = DCS_RevisionItemNo,
    OriginalFileName = DCS_OriginalFileName,
    FileName = DCS_FileName,
    FileSize = DCS_FileSize,
    FileRef = DCS_FileRef,
    object_guid,
    md5hash,
    InstancesInFileDownloads = (
        select count(*)
        from dbo.ltbl_Import_DTS_DCS_Files F with (nolock)
        where F.OriginalFileName = RF.OriginalFileName
    ),
    InstancesInPimsRevisionsFiles = (
        select count(*)
        from dbo.atbl_DCS_RevisionsFiles DcsRF with (nolock)
        where
            DcsRF.Domain = RF.DCS_Domain
            and DcsRF.DocumentID = RF.DCS_DocumentID
            and DcsRF.RevisionItemNo = RF.DCS_RevisionItemNo
            and DcsRF.OriginalFileName = RF.DCS_OriginalFileName

    )
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles RF with (nolock)
where
    INTEGR_REC_ERROR like @ErrorPattern
    and INTEGR_REC_GROUPREF =  @GroupRef
