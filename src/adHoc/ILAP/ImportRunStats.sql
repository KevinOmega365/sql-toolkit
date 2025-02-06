
/*
 * Bin runs by run date-hour
 */
-- select
--     Created,
--     RunID = rank() over (order by dateadd(hour, datediff(hour, 0, Created), 0))
-- from
--     dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock)
-- order by
--     Created desc

/*
 * step count
 */
-- select
--     RunID,
--     StepCount = count(*)
-- from
-- (
--     select
--         Created,
--         RunID = rank() over (order by dateadd(hour, datediff(hour, 0, Created), 0))
--     from
--         dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock)
-- ) T
-- group by
--     RunID
-- order by RunID
--     desc

/*
 * Run duration -- obs: does not count the lengh of the last step
 */
select
    RunStart = min(Created),
    RunID,
    StepCount = count(*),
    ActivityCreationTimeSpanMin = datediff(second, min(Created), max(Created)) / 60.0
from
(
    select
        Created,
        RunID = rank() over (order by dateadd(hour, datediff(hour, 0, Created), 0))
    from
        dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock)
) T
group by
    RunID
having
    count(*) = 20
order by
    RunID desc

/**
 * all your base
 */
-- select * from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock) order by Created desc
