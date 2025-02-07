
/*
 * filesize ntile
 */
declare @parts int = 12
select 
    Quantile,
    Max(FileSize)
from
(
    select
        FileSize,
        Quantile = ntile(@parts) over (order by FileSize)
    from
        dbo.ltbl_Import_DTS_DCS_Files with (nolock)
) T
group by
    Quantile
