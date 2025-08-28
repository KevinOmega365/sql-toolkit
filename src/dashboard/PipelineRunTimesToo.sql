
declare @lastNumberOfMonths int = 3
select
    Name,
    MinExecutionTimeSeconds = min(ExecutionTime),
    AvgExecutionTimeSeconds = avg(ExecutionTime),
    MaxExecutionTimeSeconds = max(ExecutionTime)
from
(
    select
        Name,
        ExecutionBatchRef,
        Max(Initiated) as Initiated,
        Min(ExecutionStart) as ExecutionStart,
        Max(ExecutionEnd) as ExecutionEnd,
        ExecutionTime = datediff(second, Min(ExecutionStart), Max(ExecutionEnd))
    from dbo.aviw_Integrations_ScheduledTasksActivityMonitor
    where
        GroupRef in (
            '7b3cb1c6-350b-4422-be48-19c9cbb40dc9',
            'b1b10725-ef02-4621-be95-a157871883b8',
            'f51764af-7c2c-43d9-8a34-6aa1c59b8ea8'
        )
        and Initiated > cast(dateadd(month, - @lastNumberOfMonths, getdate()) as date)
    group by
        Name, ExecutionBatchRef
) T
group by
    Name

/*
 * Running times
 */
-- select
--     Name,
--     -- ExecutionBatchRef,
--     Max(Initiated) as Initiated,
--     Min(ExecutionStart) as ExecutionStart,
--     Max(ExecutionEnd) as ExecutionEnd,
--     ExecutionTime = datediff(second, Min(ExecutionStart), Max(ExecutionEnd))
-- from dbo.aviw_Integrations_ScheduledTasksActivityMonitor
-- where
--     GroupRef in (
--         '7b3cb1c6-350b-4422-be48-19c9cbb40dc9',
--         'b1b10725-ef02-4621-be95-a157871883b8',
--         'f51764af-7c2c-43d9-8a34-6aa1c59b8ea8'
--     )
-- group by
--     Name, ExecutionBatchRef
-- order by
--     Max(Initiated) desc

/*
 * Sample
 */
-- select top 10 *
-- from dbo.aviw_Integrations_ScheduledTasksActivityMonitor
