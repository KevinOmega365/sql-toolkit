
-- select
--     Documents = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)),
--     Documents_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_Documents_RAW with (nolock)),
--     Revisions = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)),
--     Revisions_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_Revisions_RAW with (nolock)),
--     RevisionsFiles = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)),
--     RevisionsFiles_RAW = (select count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles_RAW with (nolock))

select
    facilityCode,
    Count = count(*)
from
    dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
group by
    facilityCode

select
    facilityCode = facility_code,
    Count = count(*)
from
    dbo.ltbl_Import_ProArc_Documents with (nolock)
group by
    facility_code

select
    facilityCode,
    Count = count(*)
from
    dbo.ltbl_Import_MuninAibel_Documents with (nolock)
group by
    facilityCode
