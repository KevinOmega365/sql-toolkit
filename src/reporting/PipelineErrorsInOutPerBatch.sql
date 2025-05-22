/*
 * What I want to know
 *   How many records came in
 *   Records went out
 *   How many records stayed
 */

-- Batches in order
-- Previous Batch
-- How many are in both
-- How many are in previous only 
-- How many are not in previous

-------------------------------------------------------------------------------

declare @Batches table (
    GroupRef uniqueidentifier,
    BatchRef uniqueidentifier,
    Previous uniqueidentifier,
    Created datetime2,
    BatchNumber int
)

insert into @Batches (
    GroupRef,
    BatchRef,
    Created
)
select
    GroupRef = INTEGR_REC_GROUPREF,
    BatchRef = INTEGR_REC_BATCHREF,
    Created = max(Created)
from
    dbo.ltbl_Import_DTS_DCS_ErrorsInstances with (nolock)
group by
    INTEGR_REC_BATCHREF,
    INTEGR_REC_GROUPREF

-------------------------------------------------------------------------------

update Batches
set Batches.BatchNumber = BatchNumbers.BatchNumber
from
    @Batches Batches
    join (
        select
            BatchRef,
            BatchNumber = row_number() over(partition by GroupRef order by Created)
        from
            @Batches
    ) BatchNumbers
        on BatchNumbers.BatchRef = Batches.BatchRef

-------------------------------------------------------------------------------

update Batches
set Batches.Previous = PreviousBatchs.BatchRef
from
    @Batches Batches
    join @Batches PreviousBatchs
        on PreviousBatchs.GroupRef = Batches.GroupRef
        and PreviousBatchs.BatchNumber = Batches.BatchNumber - 1

-------------------------------------------------------------------------------

select
    CreatedDateHour = convert(nvarchar(13), Created, 120), -- cast(Created as date), --
    ErrorCount = (
        select count(*)
        from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
        where EI.INTEGR_REC_BATCHREF = B.BatchRef
    ),
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups as G with (nolock)
        where G.PrimKey = B.GroupRef
    ),
    ErrorsIn = (
        select count(*)
        from (
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.BatchRef
            except
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.Previous
            
        ) T
    ),
    ErrorsOver = (
        select count(*)
        from (
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.BatchRef
            intersect
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.Previous
            
        ) T
    ),
    ErrorsOut = (
        select count(*)
        from (
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.Previous
            except
            select ErrorRef
            from dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
            where EI.INTEGR_REC_BATCHREF = B.BatchRef
            
        ) T
    )
    -- ,GroupRef,
    -- BatchRef,
    -- Previous,
    -- Created,
    -- BatchNumber
from
    @Batches B
order by
    GroupRef,
    Created

-------------------------------------------------------------------------------
