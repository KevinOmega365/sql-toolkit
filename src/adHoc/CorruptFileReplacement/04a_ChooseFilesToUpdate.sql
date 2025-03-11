DECLARE @ACTION_UPDATE_FILE AS NVARCHAR(50) = 'ACTION_UPDATE_FILE'
DECLARE @NO_CHANGE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='NO_CHANGE')

/*
 * Ignore revision-File with identical content
 */
-- -- update FRR set
-- select
--     INTEGR_REC_TRACE = JSON_MODIFY(
--         ISNULL(NULLIF(FRR.INTEGR_REC_TRACE, ''), '{}'),
--         'append $.action',
--         'Revision-File with identical content already exists'
--     )
--     ,INTEGR_REC_STATUS = @NO_CHANGE
-- from
--     dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
--     join dbo.atbl_DCS_RevisionsFiles P_RF with (nolock)
--         on P_RF.PrimKey = FRR.DcsRevFileRef
-- where
--     P_RF.FileRef = FRR.DCS_FileRef
--     and FRR.INTEGR_REC_STATUS = 'IMPORTED_OK'

/*
 * Voided Revisions
 */
-- -- update FRR set
-- select
--     INTEGR_REC_STATUS = @ACTION_UPDATE_FILE
-- from
--     dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
--     join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I_RF with (nolock)
--         on I_RF.object_guid = FRR.object_guid
--     join dbo.atbl_DCS_RevisionsFiles P_RF with (nolock)
--         on P_RF.PrimKey = FRR.DcsRevFileRef
--     join dbo.atbl_DCS_Revisions P_R with (nolock)
--         on P_R.Domain = I_RF.DCS_Domain
--         and P_R.DocumentID = I_RF.DCS_DocumentID
--         and P_R.RevisionItemNo = I_RF.DCS_RevisionItemNo
-- where
--     P_R.Step = 'V'
--     and FRR.INTEGR_REC_STATUS = 'IMPORTED_OK'

/*
 * Non-current revision files with "review" step
 */
-- -- update FRR set
-- select
--     INTEGR_REC_STATUS = @ACTION_UPDATE_FILE
-- from
--     dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
--     join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I_RF with (nolock)
--         on I_RF.object_guid = FRR.object_guid
--     join dbo.atbl_DCS_RevisionsFiles P_RF with (nolock)
--         on P_RF.PrimKey = FRR.DcsRevFileRef
--     join dbo.atbl_DCS_Revisions P_R with (nolock)
--         on P_R.Domain = I_RF.DCS_Domain
--         and P_R.DocumentID = I_RF.DCS_DocumentID
--         and P_R.RevisionItemNo = I_RF.DCS_RevisionItemNo
--     join dbo.atbl_DCS_Documents P_D with (nolock)
--         on P_D.Domain = P_R.Domain
--         and P_D.DocumentID = P_R.DocumentID
-- where
--     P_D.CurrentRevision <> P_R.Revision
--     and FRR.INTEGR_REC_STATUS = 'IMPORTED_OK'
--     and right(P_R.Step, 1) = 'R'

/*
 * Current revision files with "review" step
 */
-- -- update top (50) FRR set
-- select
--     INTEGR_REC_STATUS = @ACTION_UPDATE_FILE
-- from
--     dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
--     join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I_RF with (nolock)
--         on I_RF.object_guid = FRR.object_guid
--     join dbo.atbl_DCS_RevisionsFiles P_RF with (nolock)
--         on P_RF.PrimKey = FRR.DcsRevFileRef
--     join dbo.atbl_DCS_Revisions P_R with (nolock)
--         on P_R.Domain = I_RF.DCS_Domain
--         and P_R.DocumentID = I_RF.DCS_DocumentID
--         and P_R.RevisionItemNo = I_RF.DCS_RevisionItemNo
--     join dbo.atbl_DCS_Documents P_D with (nolock)
--         on P_D.Domain = P_R.Domain
--         and P_D.DocumentID = P_R.DocumentID
-- where
--     P_D.CurrentRevision = P_R.Revision
--     and FRR.INTEGR_REC_STATUS = 'IMPORTED_OK'
--     and right(P_R.Step, 1) = 'R'

/*
 * All of the rest
 */
-- -- update top (500) FRR set
-- select
--     INTEGR_REC_STATUS = @ACTION_UPDATE_FILE
-- from
--     dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
-- where
--     FRR.INTEGR_REC_STATUS = 'IMPORTED_OK'
