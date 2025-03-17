
-------------------------------------------------------------------------------

declare @StepKey uniqueidentifier = '468dc565-4017-4a0f-afb1-c8d365736807'
-- declare @NewSeq nvarchar(11) = '3' -- push 3
-- declare @NewSeq nvarchar(11) = '2' -- push 2 and 3
-- declare @NewSeq nvarchar(11) = '1' -- open spot
-- declare @NewSeq nvarchar(11) = '1.1.1.2' -- push ...2
-- declare @NewSeq nvarchar(11) = '1.1.1.1' -- no change
-- declare @NewSeq nvarchar(11) = '1.1.1.13' -- open spot
-- declare @NewSeq nvarchar(11) = '1.1.1.15' -- push ...15 and ...16
declare @NewSeq nvarchar(11) = '1.1.1.16' -- push ...16

-------------------------------------------------------------------------------

declare @Steps table
(
    primKey uniqueidentifier,
    seq NVARCHAR(11)
)
insert into @Steps
values
    ('468dc565-4017-4a0f-afb1-c8d365736807','1.1.1.1'),
    ('a0f6f1cd-2b30-46b7-8a8e-0f1f589dc35c','1.1.1.2'),
    ('141d2208-b25b-471d-b5f5-0cc5d2e6748e','1.1.1.15'),
    ('5478fcb0-34ed-4384-92ab-a6fa1feb137e','1.1.1.16'),
    (newid(), '2'),
    (newid(), '3')
select * into #Steps from @Steps

-------------------------------------------------------------------------------

declare @TempSequenceOrder nvarchar(11) = '999'

-- declare @numDots int = len(@NewSeq) - LEN(REPLACE(@NewSeq, '.', ''))

declare @leaf int =
    case
        when charindex('.', @NewSeq) > 0
        then reverse(left(reverse(@NewSeq), charindex('.', reverse(@NewSeq)) - 1))
        else @NewSeq
    end

declare @head nvarchar(9) =
    case
        when charindex('.', @NewSeq) > 0
        then left(@NewSeq, len(@NewSeq) - charindex('.', reverse(@NewSeq)) + 1) -- include dot
        else ''
    end

-------------------------------------------------------------------------------
--------------------------------------------------------------solution (wip) --
-------------------------------------------------------------------------------

declare @TasksOffsetGroups table
(
    OffsetGroup int,
    TaskRef uniqueidentifier,
    IncrementedSequenceOrder nvarchar(11)
)

insert into @TasksOffsetGroups
(
    OffsetGroup,
    TaskRef,
    IncrementedSequenceOrder
)
select
    OffsetGroup = leaf - rowNum,
    PrimKey,
    IncrementedSequenceOrder = head + cast(leaf + 1 as nvarchar(2))
from
(
    select
        *,
        rowNum = row_number() over(order by dbo.afnc_Integrations_GetSortOrder(seq))
    from
    (
        select
            *,
            -- numDots = len(seq) - LEN(REPLACE(seq, '.', '')),
            leaf = case
                when charindex('.', seq) > 0
                then reverse(left(reverse(seq), charindex('.', reverse(seq)) - 1))
                else seq
            end,
            head = case
                when charindex('.', seq) > 0
                then left(seq, len(seq) - charindex('.', reverse(seq)) + 1) -- include dot
                else ''
            end
        from
            @Steps
    ) T
    where
        head = @head
        and leaf >= @leaf
        -- and numDots = @numDots -- cruft?
) U

/*
 * Offset Group to Update
 */
declare @OffsetGroupToUpdate int = (select min(OffsetGroup) from @TasksOffsetGroups)

-------------------------------------------------------------------------------

update @Steps
set
    seq = @TempSequenceOrder
from
    @Steps T
where
    PrimKey = @StepKey

--

update S
set
    seq = IncrementedSequenceOrder
from
    @Steps S
    join @TasksOffsetGroups TOG
        on S.PrimKey = TOG.TaskRef
where
    TOG.OffsetGroup = @OffsetGroupToUpdate

--

update @Steps
set
    seq = @NewSeq
from
    @Steps T
where
    PrimKey = @StepKey
    
-------------------------------------------------------------------------------

/*
 * side by side
 */
select
    OldPrimKeyPosition = OriginalTasks.PrimKey,
    OldSequenceOrder = OriginalTasks.seq,
    NewSequenceOrder = UpdatedTasks.seq,
    NewPrimKeyPosition = UpdatedTasks.PrimKey
from
(
    select
        rowNum = row_number() over (order by dbo.afnc_Integrations_GetSortOrder(seq)),
        *
    from
        @Steps
) UpdatedTasks
join (
    select
        rowNum = row_number() over (order by dbo.afnc_Integrations_GetSortOrder(seq)),
        *
    from
        #Steps
) OriginalTasks
    on OriginalTasks.rowNum = UpdatedTasks.rowNum

-------------------------------------------------------------------------------
