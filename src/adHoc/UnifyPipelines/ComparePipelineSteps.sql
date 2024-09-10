select
    Count = count(*),
    Step.SequenceOrder,
    Step.Name
from 
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Step WITH (NOLOCK)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipeline WITH (NOLOCK)
        on Pipeline.PrimKey = Step.GroupRef
where
    Pipeline.Name LIKE '%dts%docu%'
    and Pipeline.Inactive = 0
group by
    Step.SequenceOrder,
    Step.Name
order by
    cast(Step.SequenceOrder as float), -- this won't work for cases like 1.2.3
    Step.Name
