select
    DocumentCount = count(*),
    FacilityCode,
    TableNameSpace
from
    (
        select
            FacilityCode = facility_code,
            TableNameSpace = 'ProArc'
        from
            dbo.ltbl_Import_ProArc_Documents with (nolock)
    )
    SuperCoolTableAliasAndDeeplyMeaningfulNotLeast
group by
    FacilityCode,
    TableNameSpace
    
UNION ALL

select
    DocumentCount = count(*),
    FacilityCode,
    TableNameSpace
from
    (
        select
            FacilityCode = facilityCode,
            TableNameSpace = 'MuninAibel'
        from
            dbo.ltbl_Import_MuninAibel_Documents with (nolock)
    )
    SuperCoolTableAliasAndDeeplyMeaningfulNotLeast
group by
    FacilityCode,
    TableNameSpace

order by facilityCode