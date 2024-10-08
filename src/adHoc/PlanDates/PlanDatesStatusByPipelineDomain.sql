select
    DCS_Domain,
    INTEGR_REC_STATUS,
    Count = Count(*)
from
    dbo.ltbl_Import_DTS_DCS_DocumentsPlan as [DTS] with (nolock)
group by
    DCS_Domain,
    INTEGR_REC_STATUS
order by
    DCS_Domain,
    INTEGR_REC_STATUS