select
    OccuranceCount = count(*),
    RevisionCount
from
(
    select
        RevisionCount = count(*)
    from
(
    select
        D.Domain, D.DocumentID, Revision
    from
        dbo.atbl_DCS_Documents D with (nolock)
        left join dbo.atbl_DCS_Revisions R_Revision with (nolock)
            on R_Revision.Domain = D.Domain
            and  R_Revision.DocumentID = D.DocumentID
            and  R_Revision.Revision = D.CurrentRevision
    where
        D.Domain in ('128', '187')

    union

    select
        D.Domain, D.DocumentID, Revision
    from
        dbo.atbl_DCS_Documents D with (nolock)
        left join dbo.atbl_DCS_Revisions R_ID with (nolock)
            on R_ID.ID = D.CurrentRevision_ID
    where
        D.Domain in ('128', '187')

    union

    select
        D.Domain, D.DocumentID, Revision
    from
        dbo.atbl_DCS_Documents D with (nolock)
        left join dbo.atbl_DCS_Revisions R_RevisionItemNo with (nolock)
            on R_RevisionItemNo.Domain = D.Domain
            and  R_RevisionItemNo.DocumentID = D.DocumentID
            and  R_RevisionItemNo.RevisionItemNo = D.CurrentRevisionItemNo
    where
        D.Domain in ('128', '187')


) U
    group by
        Domain,
        DocumentID
) T
group by
    RevisionCount
order by
    RevisionCount
