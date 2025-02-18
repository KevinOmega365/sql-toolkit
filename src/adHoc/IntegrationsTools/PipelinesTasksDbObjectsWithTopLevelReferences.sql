-------------------------------------------------------------------------------

declare @databaseObjectPattern nvarchar(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw

-------------------------------------------------------------------------------

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Yggdrasil -- '%'

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

/*
 * Pipelines Tasks DB Objects
 */
select
    PipelineName = Pipelines.Name,
    TaskName = Tasks.Name,
    Tasks.StepType,
    ConfigKey = [key],
    ConfigValue = value,
    ReferenceCount = (
        select count(distinct referenced_entity_name)
        from sys.dm_sql_referenced_entities(
            'dbo.' + value,
            'OBJECT'
        )
    ),
    ReferenceList = (
        select string_agg(referenced_entity_name, ', ') within group (order by referenced_entity_name)
        from
        (
            select distinct referenced_entity_name
            from sys.dm_sql_referenced_entities(
                'dbo.' + value,
                'OBJECT'
            )
        ) T
    )
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
        on Tasks.GroupRef = Pipelines.PrimKey
    cross apply openjson(StepConfig)
where
    value like @databaseObjectPattern
    and Pipelines.PrimKey like @GroupRef
