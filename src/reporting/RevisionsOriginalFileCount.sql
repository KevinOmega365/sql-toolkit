
/*
    Questions
        How many are orphaned
        How many are duplicated
*/

-- join through import table
-- case is not null 1 else 0
-- group by fileref and sum
-- count by document-currentrevision-fileref
-- 

/*
 * Document links
 */
-- select
--     LinkDetails.Domain,
--     LinkDetails.DocumentID,
--     LinkDetails.Revision,
--     Link = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open")',
--     RevisionsFileCounts.OriginalFileCount
-- from
-- (
--     select
--         OriginalFileCount = count(*),
--         R.PrimKey
--     from
--         dbo.atbl_DCS_Documents as D with (nolock)
--         join dbo.atbl_DCS_Revisions as R with (nolock)
--             on R.Domain = D.Domain
--             and R.DocumentID = D.DocumentID
--             and R.Revision = D.CurrentRevision
--         join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
--             on RF.Domain = R.Domain
--             and RF.DocumentID = R.DocumentID
--             and RF.RevisionItemNo = R.RevisionItemNo
--     where
--         D.Domain in ('128', '187')
--         and RF.Type = 'Original'
--     group by
--         R.PrimKey
--     having
--         count(*) > 1
-- ) as RevisionsFileCounts
-- outer apply (
--     select
--         Domain,
--         DocumentID,
--         Revision
--     from
--         dbo.atbl_DCS_Revisions as Details with (nolock)
--     where
--         Details.PrimKey = RevisionsFileCounts.PrimKey
-- ) as LinkDetails
-- order by
--     OriginalFileCount desc,
--     DocumentID

/*
 * Count: "Original" files
 */
-- select
--     OriginalFileCount = FileCount,
--     InstanceCount = count(*)
-- from (
--     select
--         FileCount = count(*)
--     from
--         dbo.atbl_DCS_Documents as D with (nolock)
--         join dbo.atbl_DCS_Revisions as R with (nolock)
--             on R.Domain = D.Domain
--             and R.DocumentID = D.DocumentID
--             and R.Revision = D.CurrentRevision
--         join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
--             on RF.Domain = R.Domain
--             and RF.DocumentID = R.DocumentID
--             and RF.RevisionItemNo = R.RevisionItemNo
--     where
--         D.Domain in ('128', '187')
--         and RF.Type = 'Original'
--     group by
--         R.PrimKey
-- ) T
-- group by
--     FileCount
-- order by
--     FileCount desc

/*
 * Count: file types
 */
-- select
--     RF.Type,
--     InstanceCount = count(*)
-- from
--     dbo.atbl_DCS_Documents as D with (nolock)
--     join dbo.atbl_DCS_Revisions as R with (nolock)
--         on R.Domain = D.Domain
--         and R.DocumentID = D.DocumentID
--         and R.Revision = D.CurrentRevision
--     join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
--         on RF.Domain = R.Domain
--         and RF.DocumentID = R.DocumentID
--         and RF.RevisionItemNo = R.RevisionItemNo
-- where
--     D.Domain in ('128', '187')
-- group by
--     RF.Type

/*
 * Count: current revision files
 */
-- select count(*)
-- from
--     dbo.atbl_DCS_Documents as D with (nolock)
--     join dbo.atbl_DCS_Revisions as R with (nolock)
--         on R.Domain = D.Domain
--         and R.DocumentID = D.DocumentID
--         and R.Revision = D.CurrentRevision
--     join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
--         on RF.Domain = R.Domain
--         and RF.DocumentID = R.DocumentID
--         and RF.RevisionItemNo = R.RevisionItemNo
-- where
--     D.Domain in ('128', '187')