declare @ServiceName nvarchar(128)=N'Integrations.Interface.RestAPI'

select
    RunDate = cast(L.Created as date),
    Count = count(*),
    L.ExecutionBatchRef,
    Pipeline = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups G with (nolock)
        where G.PrimKey = L.ExecutionGroupRef
    ),
    L.ExecutionGroupRef,
    TaskName = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks T with (nolock)
        where T.PrimKey = L.ExecutionTaskRef
    ),
    L.ExecutionTaskRef
from
    dbo.atbl_Integrations_ScheduledTasksServicesLog aS L with (nolock)
where
    [ServiceName] = @Param0
    and Created > cast(dateadd(day, - 28, getdate()) as date)
group by
    cast(L.Created as date),
    L.ExecutionBatchRef,
    L.ExecutionGroupRef,
    L.ExecutionTaskRef
order by
    RunDate desc,
    L.ExecutionBatchRef,
    L.ExecutionGroupRef,
    L.ExecutionTaskRef