select
    Count = sum(GroupCount),
    DistributionFlag
from
(
    select
        GroupCount = Count,
        DistributionFlag
    from
        (
            select Count = count(*), otherCompanyDistributions
            from dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
            where INTEGR_REC_GROUPREF = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
            group by otherCompanyDistributions
        ) T
        cross apply openjson(otherCompanyDistributions)
            with(DistributionFlag nvarchar(max) '$.value') F
) U
group by
    DistributionFlag
    
-- select count(*), otherCompanyDistributions
-- from dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
-- where INTEGR_REC_GROUPREF = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
-- group by otherCompanyDistributions