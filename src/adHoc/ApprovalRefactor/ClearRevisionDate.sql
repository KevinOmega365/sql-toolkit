declare @Domain nvarchar(128) = '035'
declare @DocumentID nvarchar(128) = '3203-T-VAB-I-XL-16-0010-01;7005547;230030'
declare @RevisionItemNo nvarchar(64) = '3'

-- update R
-- set RevisionDate = null
-- from dbo.atbl_DCS_Revisions R with (nolock)
-- where
--     Domain = @Domain
--     and DocumentID = @DocumentID
--     and RevisionItemNo = @RevisionItemNo

select * from dbo.atbl_DCS_Revisions with (nolock)
where
    Domain = @Domain
    and DocumentID = @DocumentID
    and RevisionItemNo = @RevisionItemNo