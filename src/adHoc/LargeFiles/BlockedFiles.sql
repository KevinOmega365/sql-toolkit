select
    count(*) as Count,
    DCS_Domain,
    cast(min(fileSize) as bigint) / 1000000 as MinFileSizeMb,
    cast(max(fileSize) as bigint) / 1000000 as MaxFileSizeMb
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
where
    INTEGR_REC_TRACE is not null
    and INTEGR_REC_TRACE like '%Maximum file size exceeded%'
group by
    DCS_Domain
