
-- Under-sized files created by integrations service user

/**
 * Document details
 */
select
    F.Created,
    F.CreatedBy,
    F.Domain,
    F.DocumentID,
    PimsLink = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";C2;"&DocID=";D2);"Open in Pims")',
    RevisonAndCurrent = R.Revision + case when R.Revision <> D.CurrentRevision then ' ( ' + D.CurrentRevision + ' )' else '' end,
    R.Step,
    F.FileSize,
    F.FileName,
    F.OriginalFileName
from
    dbo.atbl_DCS_RevisionsFiles F with (nolock)
    join dbo.atbl_DCS_Revisions R with (nolock)
        on R.Domain = F.Domain
        and R.DocumentID = F.DocumentID
        and R.RevisionItemNo = F.RevisionItemNo
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = R.Domain
        and D.DocumentID = R.DocumentID
where
    F.CreatedBy = 'af_Integrations_ServiceUser'
    and F.FileSize < 1000
order by
    Domain 

/**
 * Domains, counts and size samples
 */
select
    sum(Count) as Count,
    Domain,
    Sizes = string_agg( cast( FileSize as nvarchar( max ) ), ', ' )
from
(
    select
        Count = count(*),
        Domain,
        FileSize
    from
        dbo.atbl_DCS_RevisionsFiles with (nolock)
    where
        CreatedBy = 'af_Integrations_ServiceUser'
        and FileSize < 1000
    group by
        Domain,
        FileSize
) T
group by
    Domain
order by
    Domain

/**
 * Domains counts
 */
select
    Count = count(*),
    Domain
from
    dbo.atbl_DCS_RevisionsFiles with (nolock)
where
    CreatedBy = 'af_Integrations_ServiceUser'
    and FileSize < 1000
group by
    Domain

/**
 * Simple count
 */
select
    Count = count(*)
from
    dbo.atbl_DCS_RevisionsFiles with (nolock)
where
    CreatedBy = 'af_Integrations_ServiceUser'
    and FileSize < 1000