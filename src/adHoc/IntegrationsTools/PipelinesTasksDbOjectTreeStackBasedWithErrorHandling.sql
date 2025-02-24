-------------------------------------------------------------------------------
declare @databaseObjectPattern nvarchar(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw
-------------------------------------------------------------------------------
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde',
    @MipsFromStaging uniqueidentifier = 'e8b280ec-2332-4e9e-89c9-13dda9e39bf5',
    @MipsToStaging uniqueidentifier = '8eea5c84-1cb6-4c95-9f16-b22de8764d3a'
declare @GroupRef nvarchar(36) = @MipsToStaging -- '%'
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
-- DROP TABLE IF EXISTS #PreviousWork
DROP TABLE IF EXISTS #Result
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack
(
    StackRecordID INT IDENTITY(1, 1),
    TaskID uniqueidentifier,
    ParentObjectID int,
    ObjectID int,
    RootObjectID int,
    Path nvarchar(max),
    Error nvarchar(max)
)

-- CREATE TABLE #PreviousWork ()

CREATE TABLE #Result
(
    TaskID uniqueidentifier,
    ParentObjectID int,
    ObjectID int,
    RootObjectID int,
    Path nvarchar(max),
    Error nvarchar(max)
)
-------------------------------------------------------------------------------
declare
    @StackRecordID int,
    @TaskID uniqueidentifier,
    @ParentObjectID int,
    @ObjectID int,
    @RootObjectID int,
    @Path nvarchar(max),
    @Error nvarchar(max),
    @is_incomplete bit
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

---------------------------------------------------------- Load initial data --
insert into #ProcessingStack (
    TaskID,
    ParentObjectID,
    ObjectID,
    RootObjectID,
    Path
)
    select
        TaskID = Tasks.Primkey,
        ParentObjectID = null,
        ObjectID = object_id('dbo.' + value),
        RootObjectID = object_id('dbo.' + value),
        Path = cast('|' + cast(object_id('dbo.' + value) as nvarchar(11)) + '|' as nvarchar(max))
    from
        dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
        join dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
            on Tasks.GroupRef = Pipelines.PrimKey
        cross apply openjson(StepConfig)
    where
        value like @databaseObjectPattern
        and Pipelines.PrimKey like @GroupRef
-------------------------------------------------------------------------------
while(exists (select * from #ProcessingStack))
begin
    /*
     *  get the top of the stack
     */
    select top 1
        @StackRecordID = StackRecordID,
        @TaskID = TaskID,
        @ParentObjectID = ParentObjectID,
        @ObjectID = ObjectID,
        @RootObjectID = RootObjectID,
        @Path = Path,
        @Error = Error
    from
        #ProcessingStack
    order by
        StackRecordID desc

    /*
     * pop the stack
     */
    delete #ProcessingStack
    where StackRecordID = @StackRecordID

    begin try
        /*
         * Check for binding errors
         */
        select @is_incomplete = max(cast(is_incomplete as int))
        from
            sys.dm_sql_referenced_entities(
                OBJECT_SCHEMA_NAME(@ObjectID) + '.' + OBJECT_NAME(@ObjectID),
                'OBJECT'
            )

        /*
        * push on to the stack
        */
        insert into #ProcessingStack (
            TaskID,
            ParentObjectID,
            ObjectID,
            RootObjectID,
            Path
        )
        select distinct
            TaskID = @TaskID,
            ParentObjectID = @ObjectID,
            ObjectID = referenced_id,
            RootObjectID = @RootObjectID,
            Path = @Path + cast(referenced_id as nvarchar(11))  + '|'
        from
            sys.dm_sql_referenced_entities(
                OBJECT_SCHEMA_NAME(@ObjectID) + '.' + OBJECT_NAME(@ObjectID),
                'OBJECT'
            )
        where
            @Path not like '%' + cast(referenced_id as nvarchar(11)) + '%' -- no loop !
    end try
    begin catch
        print ERROR_MESSAGE()
    end catch
    

    /*
     * add to results
     */
    insert into #Result (
        TaskID,
        ParentObjectID,
        ObjectID,
        RootObjectID,
        Path,
        Error
    )
    select
        @TaskID,
        @ParentObjectID,
        @ObjectID,
        @RootObjectID,
        @Path,
        Error = case when @is_incomplete = 1 then 'This object has one or more binding errors. The dependency trace is incomplete.' end

end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
select
    TaskID,
    ParentObjectID,
    ObjectID,
    RootObjectID,
    Path,
    Error
from
    #Result
-- where
--     object_name(ObjectID) = 'lstp_Import_AKSO_Mips_Queries_Validation'
-------------------------------------------------------------------------------
