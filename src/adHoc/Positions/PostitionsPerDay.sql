-------------------------------------------------------------------------------

declare
    @min_date date,
    @max_date date

-------------------------------------------------------------------------------

select
    @min_date = min(Created),
    @max_date = max(Created)
from
    dbo.atbl_Positions_Positions with (nolock)
where
    CreatedBy = 'af_Integrations_ServiceUser'

-------------------------------------------------------------------------------

declare @daysOfHistory int = datediff(day, @min_date, @max_date) + 1

-------------------------------------------------------------------------------

select
    Timeline.CreatedDate,
    Count = isnull(PositionsCreated.Count, 0)
from
    (
        select
            CreatedDate = cast(dateadd(day, -n, getdate()) as date)
        from
            (
                select n = row_number() over (order by object_id) - 1 -- zero based
                from sys.objects with (nolock)
                order by object_id
                offset 0 rows fetch next @daysOfHistory rows only
            ) T
    ) Timeline
    left join (
        select
            CreatedDate,
            count(*) as Count
        from
            (
                select cast(Created as date) as CreatedDate
                from dbo.atbl_Positions_Positions with (nolock)
                where CreatedBy = 'af_Integrations_ServiceUser'
            ) T
        group by
            CreatedDate
    ) PositionsCreated
        on PositionsCreated.CreatedDate = Timeline.CreatedDate
order by
    CreatedDate desc

-------------------------------------------------------------------------------
