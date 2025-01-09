-- FilesPursposeFileTypeCleanup.sql

/*
 * Fix
 */
-- update RF set
select
    Type = I.DCS_Type
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
    join dbo.atbl_DCS_RevisionsFiles AS RF with (nolock)
        on RF.DocumentID = I.DCS_DocumentID
        and RF.RevisionItemNo = I.DCS_RevisionItemNo
        and RF.FileRef = I.DCS_FileRef
where
    filePurpose = 'RedlineMarkup'
    and RF.Type <> I.DCS_Type

/*
 * Mismatches
 */
-- select
--     RF.Domain,
--     RF.DocumentID,
--     R.Revision,
--     RF.Filename,
--     I.filePurpose,
--     I.DCS_Type,
--     RF.Type,
--     FileCreated = RF.Created,
--     FileCreatedBy = RF.CreatedBy,
--     FileUpdated = RF.Updated,
--     FileUpdatedBy = RF.UpdatedBy
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
--     join dbo.atbl_DCS_RevisionsFiles AS RF with (nolock)
--         on RF.DocumentID = I.DCS_DocumentID
--         and RF.RevisionItemNo = I.DCS_RevisionItemNo
--         and RF.FileRef = I.DCS_FileRef
--     join dbo.atbl_DCS_Revisions R with (nolock)
--         on R.Domain = RF.Domain
--         and R.DocumentID = RF.DocumentID
--         and R.RevisionItemNo = RF.RevisionItemNo
-- where
--     filePurpose = 'RedlineMarkup'
--     and RF.Type <> I.DCS_Type
-- order by
--     RF.Domain,
--     RF.DocumentID,
--     R.Revision

/*
 * Document Listing
 */
-- select
--     PimsLink = 'https://pims.akerbp.com/dcs-documents-details?Domain='+RF.Domain+'&DocID='+RF.DocumentID,
--     RF.Domain,
--     RF.DocumentID,
--     R.Revision,
--     RF.Filename,
--     I.filePurpose,
--     I.DCS_Type,
--     RF.Type,
--     FileCreated = RF.Created,
--     FileCreatedBy = RF.CreatedBy,
--     FileUpdated = RF.Updated,
--     FileUpdatedBy = RF.UpdatedBy
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
--     join dbo.atbl_DCS_RevisionsFiles AS RF with (nolock)
--         on RF.DocumentID = I.DCS_DocumentID
--         and RF.RevisionItemNo = I.DCS_RevisionItemNo
--         and RF.FileRef = I.DCS_FileRef
--     join dbo.atbl_DCS_Revisions R with (nolock)
--         on R.Domain = RF.Domain
--         and R.DocumentID = RF.DocumentID
--         and R.RevisionItemNo = RF.RevisionItemNo
-- where
--     filePurpose = 'RedlineMarkup'
-- order by
--     RF.Domain,
--     RF.DocumentID,
--     R.Revision

/*
 * Counts
 */
-- select
--     Count = count(*),
--     Domain,
--     filePurpose,
--     DCS_Type,
--     Type
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
--     join dbo.atbl_DCS_RevisionsFiles AS RF with (nolock)
--         on RF.Domain = I.DCS_Domain
--         and RF.DocumentID = I.DCS_DocumentID
--         and RF.RevisionItemNo = I.DCS_RevisionItemNo
--         and RF.FileRef = I.DCS_FileRef
-- where
--     filePurpose = 'RedlineMarkup'
-- group by
--     Domain,
--     filePurpose,
--     DCS_Type,
--     Type
