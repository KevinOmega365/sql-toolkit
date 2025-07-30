
declare @daysOfHistory int = 7
declare @q int = @daysOfHistory * 24

-------------------------------------------------------------------------------

declare
    @Trigger_A uniqueidentifier = '807d26b5-b3a7-47bb-8011-ed6afc4a3f46',
    @Target_A uniqueidentifier = '6b043983-2cc9-42a9-bdce-b627dd5647ad',
    @Trigger_B uniqueidentifier = '1ceba51d-2903-483d-a315-87a9e10721af',
    @Target_B_1 uniqueidentifier = '614d3832-e84e-4759-af58-7376705f322c',
    @Target_B_2 uniqueidentifier = '239c2087-0c61-4190-b6eb-0eed3d86ed27'

-------------------------------------------------------------------------------

drop table if exists #DateTimeRange
drop table if exists #LogEntries

-------------------------------------------------------------------------------

select
    Mark = convert(nvarchar(13), dateadd(hour, - n, getdate()), 120)
into
    #DateTimeRange
from
    (
        select n = row_number() over (order by object_id) - 1 -- zero based
        from sys.objects with (nolock)
        order by object_id
        offset 0 rows fetch next @q rows only
    ) T

-------------------------------------------------------------------------------

select
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock)
        where S.PrimKey = L.GroupRef
    ),
    GroupRef,
    ExecutionBatchRef,
    Initiated = convert(nvarchar(13), min(Initiated), 120)
into
    #LogEntries
from
    dbo.atbl_Integrations_ScheduledTasksExecutionLog L with (nolock)
where
    GroupRef in
    (
        @Trigger_A,
        @Target_A,
        @Trigger_B,
        @Target_B_1,
        @Target_B_2
    )
    and Created > dateadd(day, - @daysOfHistory, getdate())
group by
    GroupRef,
    ExecutionBatchRef

-------------------------------------------------------------------------------

-- select * from #DateTimeRange
-- select * from #LogEntries

select
    Mark,
    Trigger_A = case
        when exists(
            select *
            from #LogEntries LE
            where
                LE.GroupRef = @Trigger_A
                and LE.Initiated = DTR.Mark
        )
        then 'X'
        else ''
    end,
    Target_A = case
        when exists(
            select *
            from #LogEntries LE
            where
                LE.GroupRef = @Target_A
                and LE.Initiated = DTR.Mark
        )
        then 'X'
        else ''
    end,
    Trigger_B = case
        when exists(
            select *
            from #LogEntries LE
            where
                LE.GroupRef = @Trigger_B
                and LE.Initiated = DTR.Mark
        )
        then 'X'
        else ''
    end,
    Target_B_1 = case
        when exists(
            select *
            from #LogEntries LE
            where
                LE.GroupRef = @Target_B_1
                and LE.Initiated = DTR.Mark
        )
        then 'X'
        else ''
    end,
    Target_B_2 = case
        when exists(
            select *
            from #LogEntries LE
            where
                LE.GroupRef = @Target_B_2
                and LE.Initiated = DTR.Mark
        )
        then 'X'
        else ''
    end
from
    #DateTimeRange DTR
order by
    DTR.Mark desc
