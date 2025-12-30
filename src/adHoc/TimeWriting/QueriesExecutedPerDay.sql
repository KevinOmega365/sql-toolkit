
declare @TopCount int = 500

select top (@TopCount) Created into #MyDbActivity from [dbo].[sviw_DbTools_MyScripts] order by ID desc

/*
 * Queries per day
 */
select
    CreationDate,
    QueryCount = Count(*)
from
(
    select
        CreationDate = cast(Created as date)
    from
        #MyDbActivity
) T
group by
    CreationDate
order by
    CreationDate desc

/*
 * Date range
 */
select
    Earliest = min(Created),
    Latest = max(Created)
from
    #MyDbActivity

/*
 * My Latest Scripts
 */
-- SELECT TOP 25 [ID], [Created], [ObjectID], [Executed], [Definition_Truncated], [PrimKey] FROM [dbo].[sviw_DbTools_MyScripts] ORDER BY [ID] DESC
