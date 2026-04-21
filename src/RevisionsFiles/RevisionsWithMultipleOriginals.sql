
declare @DomainList table (
    Domain nvarchar(128)
)
insert into @DomainList
values
    ('128'),
    ('187')

/*
 * Document links
 */
select
    LinkDetails.Domain,
    LinkDetails.DocumentID,
    LinkDetails.Revision,
    Link = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open")',
    RevisionsFileCounts.OriginalFileCount,
    FileList
from
(
    select
        OriginalFileCount = count(*),
        R.PrimKey,
        FileList = cast(string_agg('[ ' + RF.FileName + ' (' + RF.OriginalFilename + ')' + isnull(' ' + FileDescription, '') + ' ]', ', ') as nvarchar(max))
    from
        dbo.atbl_DCS_Documents as D with (nolock)
        join dbo.atbl_DCS_Revisions as R with (nolock)
            on R.Domain = D.Domain
            and R.DocumentID = D.DocumentID
            and R.Revision = D.CurrentRevision
        join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
            on RF.Domain = R.Domain
            and RF.DocumentID = R.DocumentID
            and RF.RevisionItemNo = R.RevisionItemNo
    where
        D.Domain in (select * from @DomainList)
        and RF.Type = 'Original'
    group by
        R.PrimKey
    having
    count(*) between 3 and 4 -- = 2 -- > 4 --
) as RevisionsFileCounts
outer apply (
    select
        Domain,
        DocumentID,
        Revision
    from
        dbo.atbl_DCS_Revisions as Details with (nolock)
    where
        Details.PrimKey = RevisionsFileCounts.PrimKey
) as LinkDetails
order by
    OriginalFileCount desc,
    DocumentID

/*
 * Count: "Original" files
 */
select
    OriginalFileCount = FileCount,
    InstanceCount = count(*)
from (
    select
        FileCount = count(*)
    from
        dbo.atbl_DCS_Documents as D with (nolock)
        join dbo.atbl_DCS_Revisions as R with (nolock)
            on R.Domain = D.Domain
            and R.DocumentID = D.DocumentID
            and R.Revision = D.CurrentRevision
        join dbo.atbl_DcS_RevisionsFiles as RF with (nolock)
            on RF.Domain = R.Domain
            and RF.DocumentID = R.DocumentID
            and RF.RevisionItemNo = R.RevisionItemNo
    where
        D.Domain in (select * from @DomainList)
        and RF.Type = 'Original'
    group by
        R.PrimKey
) T
group by
    FileCount
order by
    FileCount desc

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
--     D.Domain in (select * from @DomainList)
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
--     D.Domain in (select * from @DomainList)