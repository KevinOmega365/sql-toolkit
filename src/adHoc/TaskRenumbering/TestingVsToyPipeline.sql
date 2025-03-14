
/*
 *  Make group levels
 */

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @MockGroupTasks table
(
    SequenceOrder NVARCHAR(15),
    SortOrder int,
    PrimKey uniqueidentifier
)

-------------------------------------------------------------------------------

insert into @MockGroupTasks
values
    ('1',  dbo.afnc_Integrations_GetSortOrder('1'),  newid()),
    ('2.1',  dbo.afnc_Integrations_GetSortOrder('2.1'),  newid()),
    ('2.2',  dbo.afnc_Integrations_GetSortOrder('2.2'),  newid()),
    ('3',  dbo.afnc_Integrations_GetSortOrder('3'),  newid()),
    ('4.1.1',  dbo.afnc_Integrations_GetSortOrder('4.1.1'),  newid()),
    ('4.1.2',  dbo.afnc_Integrations_GetSortOrder('4.1.2'),  newid()),
    ('4.2.1',  dbo.afnc_Integrations_GetSortOrder('4.2.1'),  newid()),
    ('4.2.3',  dbo.afnc_Integrations_GetSortOrder('4.2.3'),  newid()),
    ('7',  dbo.afnc_Integrations_GetSortOrder('7'),  newid()),
    ('8',  dbo.afnc_Integrations_GetSortOrder('8'),  newid())

-------------------------------------------------------------------------------

declare @originalSequenceOrder NVARCHAR(15) = '1'
declare @newSequenceOrder NVARCHAR(15) = '2'
declare @taskRef uniqueidentifier = 
(
    select PrimKey
    from @MockGroupTasks
    where SequenceOrder = @originalSequenceOrder
)

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
        Offset = SortOrder / 1000000 - RowNumber,
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
    -- Groups.OffsetGroup,
    Tasks.SortOrder
