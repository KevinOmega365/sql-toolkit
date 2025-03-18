    ---------------------------------------------------------------------------

    declare @databaseObjectPattern nvarchar(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw
    
    ---------------------------------------------------------------------------
    --------------------------------------------------------- Pipeline Tasks --
    ---------------------------------------------------------------------------
    -- INSERT INTO dbo.atbl_Integrations_DevTools_DatabaseObjectSources
    -- (
    --     SourceType,
    --     SourceParentRef,
    --     SourceRef,
    --     ObjectName
    -- )
    SELECT
        SourceType = 'PipelineTask',
        SourceParentRef = (
            SELECT GroupRef
            FROM dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks WITH (NOLOCK)
            WHERE PrimKey = TaskRef
        ),
        SourceRef = Tasks.Primkey,
        ParentObjectID = NULL,
        ObjectID = object_id('dbo.' + value)
    FROM
        dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines WITH (NOLOCK)
        JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks WITH (NOLOCK)
            ON Tasks.GroupRef = Pipelines.PrimKey
        CROSS APPLY OPENJSON(StepConfig)
    WHERE
        value LIKE @databaseObjectPattern

    ---------------------------------------------------------------------------
    -------------------------------------------------------- TableSet Tables --
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ---------------------------------------------- Field Mapping Subscribers --
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------------------
    ------------------------------------------------------- Endpoint Configs --
    ---------------------------------------------------------------------------
