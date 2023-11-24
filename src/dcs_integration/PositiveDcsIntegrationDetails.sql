/**
 * Positive DCS integration details
 */
 DECLARE @Domain nvarchar(128) = '181'

/**
 * Documents Created
 */
select
    Created = cast(Created as date),
    Domain,
    DocumentID,
    CreatedBy
from
    dbo.atbl_DCS_Documents D with (nolock)
where
    CreatedBy like 'af_Integrations_ServiceUser'
    and Created > dateadd(week, -1, getdate())
    and Domain = @Domain
order by
    Created desc

/**
 * Documents Updated
 */
select
    Updated = cast(Updated as date),
    Created = cast(Created as date),
    Domain,
    DocumentID,
    UpdatedBy = case when UpdatedBy <> 'af_Integrations_ServiceUser' then 'Pims DCS User' else UpdatedBy end,
    CreatedBy = case when CreatedBy <> 'af_Integrations_ServiceUser' then 'Pims DCS User' else CreatedBy end
from
    dbo.atbl_DCS_Documents D with (nolock)
where
    datediff(minute, Created, Updated) > 1
    and UpdatedBy like 'af_Integrations_ServiceUser'
    and Updated > dateadd(week, -1, getdate())
    and Domain = @Domain
order by
    Updated desc

/**
 * Revisions Created
 */
select
    Created,
    Domain,
    DocumentID,
    Revision,
    CreatedBy
from
    dbo.atbl_DCS_Revisions with (nolock)
where
    CreatedBy like 'af_Integrations_ServiceUser'
    and Created > dateadd(week, -1, getdate())
    and Domain = @Domain
order by
    Created desc

/**
 * Revision Files Created
 */
select
    RF.Created,
    RF.Domain,
    RF.DocumentID,
    R.Revision,
    RF.OriginalFileName,
    RF.FileName,
    RF.Type,
    RF.CreatedBy
from
    dbo.atbl_DCS_RevisionsFiles RF with (nolock)
    join dbo.atbl_DCS_Revisions R with (nolock)
        on R.Domain = RF.Domain
        and R.DocumentID = RF.DocumentID
        and R.RevisionItemNo = RF.RevisionItemNo
where
    RF.CreatedBy like 'af_Integrations_ServiceUser'
    and RF.Created > dateadd(week, -1, getdate()) -- todo: this could be improved
    and RF.Domain = @Domain
order by
    RF.Created desc