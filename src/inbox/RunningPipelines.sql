select distinct
    Pipeline = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
        where STCG.PrimKey = STEL.GroupRef
    )
from
    dbo.atbl_Integrations_ScheduledTasksExecutionLog STEL with (nolock)
where
    status = 'Running'

/*
Pending
Finished
Running
Halted!
*/