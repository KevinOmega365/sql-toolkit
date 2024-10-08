DECLARE
    @Param0 nvarchar(1000) = N'%dts%',
    @Param1 nvarchar(1000) = N'%docu%',
    @Param2 bit = 0

select
    Name,
    QuerySystem = (
        select
            json_value(StepConfig, '$.QuerySystem')
        from
            dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
        where
            StepType = 'API / Query System'
            and Name = 'Import Documents (RAW)'
            and Tasks.GroupRef = Pipelines.PrimKey
    ),
    GroupRef = PrimKey
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
where
    [Name] LIKE @Param0
    AND [Name] LIKE @Param1
    AND [Inactive] = @Param2