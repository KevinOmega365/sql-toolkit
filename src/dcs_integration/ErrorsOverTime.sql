-- Errors over time

-------------------------------------------------------------------------------
----------------------------------------------------------------------- Util --
-------------------------------------------------------------------------------
 /*
  * DTS - DCS pipelines
  */
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare
    @groupRef uniqueidentifier = @Valhall

/*
 * Latest Batches
 */
declare @LatestBatches table (
    INTEGR_REC_GROUPREF uniqueidentifier,
    INTEGR_REC_BATCHREF uniqueidentifier
)
insert into @LatestBatches
select
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF
from
(
    select
        INTEGR_REC_GROUPREF,
        INTEGR_REC_BATCHREF,
        BatchAge = row_number() over (partition by INTEGR_REC_GROUPREF order by BatchCreated desc)
    from
        (
            select
                INTEGR_REC_GROUPREF,
                INTEGR_REC_BATCHREF,
                BatchCreated = max(Created)
            from
                dbo.ltbl_Import_DTS_DCS_ErrorsInstances with (nolock)
            group by
                INTEGR_REC_GROUPREF,
                INTEGR_REC_BATCHREF
        ) T
) U
where
    BatchAge = 1
order by
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF

-------------------------------------------------------------------------------
---------------------------------------------------------------------- Tools --
-------------------------------------------------------------------------------

/*
 * Current errors per pipeline
 */
select
    Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock) where s.PrimKey = EI.INTEGR_REC_GROUPREF),
    EI.INTEGR_REC_BATCHREF,
    BatchDateTime = max(EI.Created),
    Count = count(*)
from
    dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
    join @LatestBatches LatestBatches
        on LatestBatches.INTEGR_REC_GROUPREF = EI.INTEGR_REC_GROUPREF
        and LatestBatches.INTEGR_REC_BATCHREF = EI.INTEGR_REC_BATCHREF
group by
    EI.INTEGR_REC_GROUPREF,
    EI.INTEGR_REC_BATCHREF
order by
    Pipeline

-------------------------------------------------------------------------------
------------------------------------------------------------------- Sketches --
-------------------------------------------------------------------------------

/*
 * Number of batches
 */
-- select
--     Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock) where s.PrimKey = EI.INTEGR_REC_GROUPREF),
--     NumberOfBatches = count(distinct INTEGR_REC_BATCHREF)
-- from
--     dbo.ltbl_Import_DTS_DCS_ErrorsInstances EI with (nolock)
-- group by
--     INTEGR_REC_GROUPREF

/*
 * Batches over time
 */
-- select
--     INTEGR_REC_GROUPREF,
--     INTEGR_REC_BATCHREF,
--     BatchCreated,
--     BatchAge -- 1 is the most recent
-- from
-- (
--     select
--         INTEGR_REC_GROUPREF,
--         INTEGR_REC_BATCHREF,
--         BatchCreated,
--         BatchAge = row_number() over (partition by INTEGR_REC_GROUPREF order by BatchCreated desc)
--     from
--         (
--             select
--                 INTEGR_REC_GROUPREF,
--                 INTEGR_REC_BATCHREF,
--                 BatchCreated = max(Created)
--             from
--                 dbo.ltbl_Import_DTS_DCS_ErrorsInstances with (nolock)
--             group by
--                 INTEGR_REC_GROUPREF,
--                 INTEGR_REC_BATCHREF
--         ) T
-- ) U
-- order by
--     INTEGR_REC_GROUPREF,
--     INTEGR_REC_BATCHREF,
--     BatchCreated desc

-- SELECT
--     RecordCount = count(*),
--     PrimKeyCount = count(distinct PrimKey),
--     ObjectRefCount = count(distinct ObjectRef),
--     PipelineCount = count(distinct INTEGR_REC_GROUPREF),
--     StatusCount = count(distinct INTEGR_REC_STATUS),
--     ErrorCount = count(distinct INTEGR_REC_ERROR),
--     TraceCount = count(distinct INTEGR_REC_TRACE)
--     FROM dbo.ltbl_Import_DTS_DCS_ErrorsDetails AS [DTS] WITH (NOLOCK) 

-- SELECT * FROM dbo.ltbl_Import_DTS_DCS_ErrorsObjects AS [DTS] WITH (NOLOCK)

-- SELECT * FROM dbo.ltbl_Import_DTS_DCS_ErrorsInstances AS [DTS] WITH (NOLOCK)
