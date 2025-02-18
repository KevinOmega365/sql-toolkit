-------------------------------------------------------------------------------

declare @databaseObjectPattern nvarchar(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw

-------------------------------------------------------------------------------

declare @JsonTypes table
(
    TypeColumnValue smallint,
    JsonDataType nvarchar(7)
)
insert into @JsonTypes
values
    (0, 'null'),
    (1, 'string'),
    (2, 'number'),
    (3, 'boolean'),
    (4, 'array'),
    (5, 'object')

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
    ConfigValue = value
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
        on Tasks.GroupRef = Pipelines.PrimKey
    cross apply openjson(StepConfig)
where
    value like @databaseObjectPattern

/*
 * DB Object Values
 */
-- select
--     StepType,
--     ConfigKey = [key],
--     ConfigValue = value
-- from
--     dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
--     cross apply openjson(StepConfig)
-- where
--     value like @databaseObjectPattern

/*
 * All the step config keys
 */
-- select
--     StepType,
--     ConfigKey,
--     DataType,
--     IsDbObject,
--     IsJson,
--     Count = count(*)
-- from
--     (
--         select
--             StepType,
--             ConfigKey = [key],
--             ConfigValue = value,
--             DataType = JT.JsonDataType,
--             IsDbObject = case when value like @databaseObjectPattern then 1 else 0 end,
--             IsJson = isjson(value)
--         from
--             dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
--             cross apply openjson(StepConfig) Entries
--             join @JsonTypes JT
--                 on JT.TypeColumnValue = Entries.type
--     ) T
-- group by
--     StepType,
--     ConfigKey,
--     DataType,
--     IsDbObject,
--     IsJson
-- order by
--     StepType,
--     ConfigKey,
--     DataType,
--     IsDbObject,
--     ISJson

/*
 * Pipeline step configs samples
 */
-- select Top 50 -- *
--     PipelineName = Pipelines.Name,
--     SequenceOrder = Tasks.SequenceOrder,
--     TaskName = Tasks.Name,
--     StepType = Tasks.StepType,
--     IsConfigJson = isjson(Tasks.StepConfig),
--     StepConfigKeys = (select string_agg([key], ', ') from (select [key] from openjson(StepConfig)) T),
--     StepConfig = Tasks.StepConfig
--     -- , *
-- from
--     dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
--     join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
--         on Tasks.GroupRef = Pipelines.PrimKey
-- where
--     isjson(Tasks.StepConfig) = 1
-- order by
--     newid()
