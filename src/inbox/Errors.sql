/**
 * Log Errors (wip)
 */
select top 50
    Pipeline = (select Name from dbo.atbl_Integrations_ScheduledTasksConfigGroups AS STCG with (nolock) where STCG.Primkey = STSL.ExecutionGroupRef),
    -- PrimKey,
    Created = CAST(Created as date),
    -- CreatedBy,
    -- Updated,
    -- UpdatedBy,
    -- ServiceName,
    CallingObject,
    CallingMethod,
    -- CallingParameters,
    Message,
    -- StackTrace,
    -- ExecutionBatchRef,
    -- ExecutionGroupRef,
    ExecutionTask = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks STCGT with (nolock) where STCGT.PrimKey = STSL.ExecutionTaskRef)
from
    dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
where
    ServiceName = 'Integrations.Interface.RestAPI'
    and Message like 'Integrations.Interface.FileDownloader.WriteFilesToFilestore : FAILED!: System.Exception: Failed to insert file in filestoretable: Field Filename cannot be blank%'
order by
    Created desc



select top 50
    Pipeline = (select Name from dbo.atbl_Integrations_ScheduledTasksConfigGroups AS STCG with (nolock) where STCG.Primkey = STSL.ExecutionGroupRef),
    Created = CAST(Created as date)
from
    dbo.atbl_Integrations_ScheduledTasksServicesLog STSL with (nolock)
where
    ServiceName = 'Integrations.Interface.RestAPI'
    and Message like 'Integrations.Interface.FileDownloader.WriteFilesToFilestore : FAILED!: System.Exception: Failed to insert file in filestoretable: Field Filename cannot be blank%'
order by
    Created desc

