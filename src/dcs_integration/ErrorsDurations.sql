

select
    SingleErrorInstances = 
        (
            select count(*)
            from
            (
                select SingleErrorInstances = count(*) 
                from dbo.ltbl_Import_DTS_DCS_ErrorsInstances as [DTS] with (nolock)
                group by ErrorRef
                having count(*) = 1
            ) T
        ),
    TotalErrorInstances = 
        (
            select count(*)
            from
            (
                select ErrorInstances = count(*)
                from dbo.ltbl_Import_DTS_DCS_ErrorsInstances as [DTS] with (nolock)
                group by ErrorRef
            ) T
        )

/*
 * Instances durations (days)
 */
-- declare @ntile int = 5
-- select
--     Count = sum(count),
--     MinDayCount = min(DayCount),
--     MaxDayCount = max(DayCount),
--     ntile = ntile
-- from
-- (
-- select
--     Count = count(*),
--     DayCount,
--     ntile = ntile(@ntile) over (order by DayCount)
-- from
-- (
--     select
--         DayCount = datediff(day, min(Created), max(Created)),
--         HourCount = datediff(hour, min(Created), max(Created)),
--         RunCount = count(*)
--     from
--         dbo.ltbl_Import_DTS_DCS_ErrorsInstances as [DTS] with (nolock)
--     group by
--         ErrorRef
-- ) T
-- group by
--     DayCount
-- ) U
-- group by
--     ntile
-- order by
--     ntile

/*
 * Errors (Days, Hours, Runs)
 */
-- select
--     DayCount = datediff(day, min(Created), max(Created)),
--     HourCount = datediff(hour, min(Created), max(Created)),
--     RunCount = count(*)
-- from
--     dbo.ltbl_Import_DTS_DCS_ErrorsInstances as [DTS] with (nolock)
-- group by
--     ErrorRef
-- order by
--     HourCount desc

/*
 * Distinct error instances
 */
-- SELECT count(distinct ErrorRef)
-- FROM
--     dbo.ltbl_Import_DTS_DCS_ErrorsInstances AS [DTS] WITH (NOLOCK)

/*
 * Random sample
 */
-- SELECT TOP 50 * FROM dbo.ltbl_Import_DTS_DCS_ErrorsInstances AS [DTS] WITH (NOLOCK) ORDER BY NEWID()
