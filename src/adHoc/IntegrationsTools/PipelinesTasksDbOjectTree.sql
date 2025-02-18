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
; with ObjectDependencyTree as
(
    select
        PipelineName = Pipelines.Name,
        Tasks.SortOrder,
        Step = Tasks.SequenceOrder,
        TaskName = Tasks.Name,
        ObjectName = cast('dbo.' + value as nvarchar(256)),
        ID = object_id('dbo.' + value),
        Depth = 0,
        ParentID = null,
        Path = cast('|' + cast(object_id('dbo.' + value) as nvarchar(11)) + '|' as nvarchar(max))
    from
        dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
        join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
            on Tasks.GroupRef = Pipelines.PrimKey
        cross apply openjson(StepConfig)
    where
        value like @databaseObjectPattern
        and Pipelines.PrimKey like @GroupRef

    union all
    
    select
        PipelineName,
        SortOrder,
        Step,
        TaskName,
        ObjectName = cast('dbo.' + referenced_entity_name as nvarchar(256)),
        ID = referenced_id,
        Depth = Depth + 1,
        ParentID = ObjectDependencyTree.ID,
        Path = ObjectDependencyTree.Path + cast(referenced_id as nvarchar(11))  + '|'
    from
        ObjectDependencyTree
        cross apply sys.dm_sql_referenced_entities(
            ObjectName,
            'OBJECT'
        )
    where
        ObjectDependencyTree.Path not like '%' + cast(referenced_id as nvarchar(11)) + '%'
)
-------------------------------------------------------------------------------
select distinct
    PipelineName,
    SortOrder,
    Task = Step + ' - ' + TaskName,
    ObjectName,
    ID,
    Depth,
    ParentID,
    Path
from
    ObjectDependencyTree
order by
    PipelineName,
    SortOrder,
    Path
