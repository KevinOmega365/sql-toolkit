/*
 * Generate string datetimes
 * to hour prescision
 * for a number of days
 * starting with this hour
 * and going back
 *
 * Uses sys.objects, which should be fine
 * if you're not going too crazy
 */
declare @daysOfHistory int = 7
declare @q int = @daysOfHistory * 24

select
    mark = convert(nvarchar(13), dateadd(hour, -n, getdate()), 120)
from
    (
        select n = row_number() over (order by object_id) - 1 -- zero based
        from sys.objects with (nolock)
        order by object_id
        offset 0 rows fetch next @q rows only
    ) T
