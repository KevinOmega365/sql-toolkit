declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'

/**
 * Mismatch
 */
select
    count = count(*),
    in_dts,
    in_fdm,
    in_both,
    dts_status,
    fdm_status,
    dts_trace,
    fdm_trace
from
    (
        select
            in_dts = case when DTS.INTEGR_REC_GROUPREF is not null then 1 else 0 end,
            in_fdm = case when FDM.INTEGR_REC_GROUPREF is not null then 1 else 0 end,
            in_both = case when DTS.INTEGR_REC_GROUPREF is not null and FDM.INTEGR_REC_GROUPREF is not null then 1 else 0 end,
            dts_status = DTS.INTEGR_REC_STATUS,
            fdm_status = FDM.INTEGR_REC_STATUS,
            dts_trace = DTS.INTEGR_REC_TRACE,
            fdm_trace = FDM.INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
            full outer join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
                on FDM.document_number = DTS.documentnumber
        where
            (
                DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
                or DTS.INTEGR_REC_GROUPREF is null
            )
            AND
            (
                FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
                or FDM.INTEGR_REC_GROUPREF is null
            )
    ) T
group by
    in_dts,
    in_fdm,
    in_both,
    dts_status,
    fdm_status,
    dts_trace,
    fdm_trace

/**
 * Mismatched counts
 */
-- select
--     in_dts = sum(in_dts),
--     in_fdm = sum(in_fdm),
--     in_both = sum(in_both)
-- from
--     (
--         select
--             in_dts = case when DTS.INTEGR_REC_GROUPREF is not null then 1 else 0 end,
--             in_fdm = case when FDM.INTEGR_REC_GROUPREF is not null then 1 else 0 end,
--             in_both = case when DTS.INTEGR_REC_GROUPREF is not null and FDM.INTEGR_REC_GROUPREF is not null then 1 else 0 end
--         from
--             dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
--             full outer join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
--                 on FDM.document_number = DTS.documentnumber
--         where
--             (
--                 DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
--                 or DTS.INTEGR_REC_GROUPREF is null
--             )
--             AND
--             (
--                 FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
--                 or FDM.INTEGR_REC_GROUPREF is null
--             )
--     ) T

/**
 * Common document counts
 */
-- select count(*)
-- from
--     dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
--     join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
--         on FDM.document_number = DTS.documentnumber
-- where
--     DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
--     AND FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef


/**
 * Base document counts
 */
select System = 'DTS', DocumentCount = count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef union all
select System = 'FDM', DocumentCount = count(*) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef