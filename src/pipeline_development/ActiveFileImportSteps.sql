/*
 * Active file download imports-steps
 */
select
    PipelineInactive = Pipeline.Inactive,
    PipelineName = Pipeline.Name,
    TaskName = Task.Name,
    TaskInactive = Task.Inactive,
    EndPointSystem = E.System,
    EndPointName = E.Name,
    FileHandlerConfigType = json_value(E.EndpointConfig, '$.FileHandlerConfig.Type')
from
    dbo.atbl_Integrations_Setup_Endpoints AS E WITH (NOLOCK)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Task WITH (NOLOCK)
        on json_value(Task.StepConfig, '$.QuerySystem') = E.System
        and json_value(Task.StepConfig, '$.QueryName') = E.Name
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipeline WITH (NOLOCK)
        on Pipeline.PrimKey = Task.GroupRef
where
    E.EndpointConfig like '%FileHandlerConfig%'