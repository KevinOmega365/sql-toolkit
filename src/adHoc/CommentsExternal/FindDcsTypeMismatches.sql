-- select
--     Domain,
--     DCS_Type,
--     Type,
--     EarliestEntry = min(I.Created),
--     Count = count(*)
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
--     join dbo.atbl_DCS_RevisionsFiles P with (nolock)
--         on Domain = DCS_Domain
--         and DocumentID = DCS_DocumentID
--         and RevisionItemNo = DCS_RevisionItemNo
--         and FileRef = DCS_FileRef
-- where
--     INTEGR_REC_GROUPREF = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
--     and DCS_Type = Type
--     and DCS_Type = 'CommentsExternal'
-- group by
--     Domain,
--     DCS_Type,
--     Type
-- order by
--     Domain,
--     DCS_Type,
--     Type

select
    Domain,
    DCS_Type,
    Type,
    Count = count(*)
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
    join dbo.atbl_DCS_RevisionsFiles with (nolock)
        on Domain = DCS_Domain
        and DocumentID = DCS_DocumentID
        and RevisionItemNo = DCS_RevisionItemNo
        and FileRef = DCS_FileRef
where
    INTEGR_REC_GROUPREF = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
    and DCS_Type <> Type
group by
    Domain,
    DCS_Type,
    Type
order by
    Domain,
    DCS_Type,
    Type
