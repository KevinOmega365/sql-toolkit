declare
    @GroupRef uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689'

/*
 * All tasks duration with concurrent tasks
 */
 select top 50
    ConcurrentTaskCount = (
        select count(*)
        from dbo.aviw_Integrations_ScheduledTasksActivityMonitor CT
        where
            CT.ExecutionStart <= T.ExecutionEnd
            and CT.ExecutionEnd >= T.ExecutionStart
            and CT.TaskRef <> T.TaskRef
    ),
    TaskName,
    ExecutionStart,
    Duration = datediff(s, ExecutionStart, ExecutionEnd),
    ErrorMsg,
    ConcurrentTasks = (
        select GroupName = Name, TaskName
        from dbo.aviw_Integrations_ScheduledTasksActivityMonitor CT
        where
            CT.ExecutionStart <= T.ExecutionEnd
            and CT.ExecutionEnd >= T.ExecutionStart
            and CT.TaskRef <> T.TaskRef
        for json auto
    )
from
    dbo.aviw_Integrations_ScheduledTasksActivityMonitor T
where
    GroupRef = @GroupRef
order by
    ExecutionStart desc
