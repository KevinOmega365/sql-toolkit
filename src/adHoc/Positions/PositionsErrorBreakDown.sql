
/*
 * Positions Error Break Down
 */
select
    Count = count(*),
    Status = INTEGR_REC_STATUS,
    Trace = INTEGR_REC_TRACE
from
    dbo.ltbl_Import_TIF_PersonsPositions as T with (nolock)
group by
    INTEGR_REC_STATUS,
    INTEGR_REC_TRACE
order by
    INTEGR_REC_STATUS,
    INTEGR_REC_TRACE
