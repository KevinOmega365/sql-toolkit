declare
    @GroupRef uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @TaskRef uniqueidentifier = '8d70430e-dc9d-4351-a3b7-54142ea373bc'

/*
 * Task duration with concurrent tasks
 */
 select top 50
    ConcurrentTaskCount = (
        select count(*)
        from dbo.aviw_Integrations_ScheduledTasksActivityMonitor CT
        where
            CT.ExecutionStart <= T.ExecutionStart
            and CT.ExecutionEnd >= T.ExecutionStart
            and CT.TaskRef <> T.TaskRef
    ),
    ExecutionStart,
    Duration = datediff(s, ExecutionStart, ExecutionEnd),
    ErrorMsg,
    ConcurrentTasks = (
        select GroupName = Name, TaskName
        from dbo.aviw_Integrations_ScheduledTasksActivityMonitor CT
        where
            CT.ExecutionStart <= T.ExecutionStart
            and CT.ExecutionEnd >= T.ExecutionStart
            and CT.TaskRef <> T.TaskRef
        for json auto
    )
from
    dbo.aviw_Integrations_ScheduledTasksActivityMonitor T
where
    GroupRef = @GroupRef
    and TaskRef = @TaskRef
order by
    ExecutionStart desc
