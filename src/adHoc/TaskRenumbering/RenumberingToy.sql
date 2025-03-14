
-------------------------------------------------------------------------------

declare @Tasks table
(
    SequenceOrder NVARCHAR(15),
    SortOrder int,
    PrimKey uniqueidentifier
)

insert into @Tasks
values
    ('1',  dbo.afnc_Integrations_GetSortOrder('1'),  newid()),
    ('2',  dbo.afnc_Integrations_GetSortOrder('2'),  newid()),
    ('3',  dbo.afnc_Integrations_GetSortOrder('3'),  newid()),
    ('4',  dbo.afnc_Integrations_GetSortOrder('4'),  newid()),
    ('7',  dbo.afnc_Integrations_GetSortOrder('7'),  newid()),
    ('8',  dbo.afnc_Integrations_GetSortOrder('8'),  newid()),
    ('11', dbo.afnc_Integrations_GetSortOrder('11'), newid()),
    ('12', dbo.afnc_Integrations_GetSortOrder('12'), newid()),
    ('13', dbo.afnc_Integrations_GetSortOrder('13'), newid()),
    ('21', dbo.afnc_Integrations_GetSortOrder('21'), newid()),
    ('22', dbo.afnc_Integrations_GetSortOrder('22'), newid()),
    ('23', dbo.afnc_Integrations_GetSortOrder('23'), newid())

select *
into #OriginalTasks
from @Tasks

-------------------------------------------------------------------------------

declare @originalSequenceOrder NVARCHAR(15) = '1'
declare @newSequenceOrder NVARCHAR(15) = '2'
declare @taskRef uniqueidentifier = 
(
    select PrimKey
    from @Tasks
    where SequenceOrder = @originalSequenceOrder
)

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
        Offset = T.SequenceOrder - RowNumber,
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
            @Tasks
    ) T
) U

-------------------------------------------------------------------------------

declare @offsetGroup int = (
    select TOG.OffsetGroup
    from
        @Tasks T
        join @TasksOffsetGroups TOG
            on TOG.TaskRef = T.PrimKey
    where
        T.SequenceOrder = @newSequenceOrder
)

-------------------------------------------------------------------------------

update @Tasks
set
    SequenceOrder = '999',
    SortOrder = dbo.afnc_Integrations_GetSortOrder('999')
from
    @Tasks T
where
    PrimKey = @taskRef

if exists(select * from @Tasks where SequenceOrder = @newSequenceOrder)
begin
    update @Tasks
    set
        SequenceOrder = SequenceOrder + 1,
        SortOrder = dbo.afnc_Integrations_GetSortOrder(SequenceOrder + 1)
    from
        @Tasks T
        join @TasksOffsetGroups TOG
            on TOG.TaskRef = T.PrimKey
    where
        T.SequenceOrder >= @newSequenceOrder
        and TOG.OffsetGroup = @offsetGroup
end

update @Tasks
set
    SequenceOrder = @newSequenceOrder,
    SortOrder = dbo.afnc_Integrations_GetSortOrder(@newSequenceOrder)
from
    @Tasks T
where
    PrimKey = @taskRef

-------------------------------------------------------------------------------

select * from
    #OriginalTasks T
join @TasksOffsetGroups TOG
on TOG.TaskRef = T.PrimKey
order by SortOrder

select * from
    @Tasks T
join @TasksOffsetGroups TOG
on TOG.TaskRef = T.PrimKey
order by SortOrder
