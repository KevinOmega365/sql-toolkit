select
    Count = count(*),
    INTEGR_REC_STATUS
from
    dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
group by
    INTEGR_REC_STATUS