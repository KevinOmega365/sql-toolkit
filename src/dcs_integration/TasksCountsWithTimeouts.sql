
/*
 * Tasks counts with (sql) timeouts
 */
select
    Count = count(*),
    Step.SequenceOrder,
    Step.Name,
    TimeoutSettings =
        string_agg(json_value(Step.StepConfig, '$.Timeout'), ', ')
        within group ( order by json_value(Step.StepConfig, '$.Timeout') )
from 
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Step WITH (NOLOCK)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipeline WITH (NOLOCK)
        on Pipeline.PrimKey = Step.GroupRef
where
    Pipeline.Description LIKE '%docu%dts%'
    and Pipeline.Inactive = 0
group by
    Step.SequenceOrder,
    Step.Name
order by
    cast(Step.SequenceOrder as float), -- this won't work for cases like 1.2.3
    Step.Name
