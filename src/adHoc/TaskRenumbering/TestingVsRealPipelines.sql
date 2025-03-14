
/*
 *  The Plan
 *    Get the groups of contiguous values
 *    Get the next diff value (what if its the last one...)
 *
 *  What about (1) => (1.1, 1.2, 2) should it be
 *    (1, 1.1, 1.2, 2) or (1, 2.1, 2.2, 3)
 */

DECLARE @TestingPipelinePrimKey UNIQUEIDENTIFIER = '98b779b1-02ef-4886-82ef-19ab350f4ab3'

/*
 * Proc parameters
 */
DECLARE @PipelineStepPrimKey UNIQUEIDENTIFIER = '9fce2e18-b4e9-4f1e-b849-257a560f1763' 
DECLARE @newSequenceOrder NVARCHAR(15) = '1.1.1'

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @MockGroupTasks table
(
    PrimKey uniqueidentifier,
    GroupRef uniqueidentifier,
    SortOrder int,
    SequenceOrder nvarchar(15)
)

insert into @MockGroupTasks
(
    PrimKey,
    GroupRef,
    SortOrder,
    SequenceOrder
)
select top 50
    PrimKey,
    GroupRef,
    SortOrder,
    SequenceOrder
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks with (nolock)
where
    GroupRef=@TestingPipelinePrimKey
order by
    SortOrder

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @TasksOffsetGroups table
(
    OffsetGroup int,
    TaskRef uniqueidentifier
)

insert into @TasksOffsetGroups
(
    OffsetGroup,
    TaskRef
)
select
    Offset,
    PrimKey
from
(
    select
        Offset = SortOrder - RowNumber * 10,
        RowNumber,  
        SequenceOrder,
        SortOrder,
        PrimKey
    from
    (
        select
            RowNumber = row_number() over (order by SortOrder),
            SequenceOrder,
            SortOrder,
            PrimKey
        from
            @MockGroupTasks
    ) T
) U

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

select *
from
    @MockGroupTasks Tasks
    join @TasksOffsetGroups Groups
        on Groups.TaskRef = Tasks.PrimKey
order by
    Groups.OffsetGroup,
    Tasks.SortOrder
