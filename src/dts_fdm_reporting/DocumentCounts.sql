declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'

/**
 * List distinct documents in FDM but not DTS
 */
select
    distinct FDM.document_number, FDM.title, FDM.INTEGR_REC_STATUS, FDM.INTEGR_REC_TRACE
from
    dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
    left join dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
        on DTS.documentnumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
    AND DTS.INTEGR_REC_GROUPREF is null
order by
    FDM.document_number,
    FDM.title

/**
 * Distinct documents in FDM but not DTS
 */
select
    DistinctDocNo = count(distinct FDM.document_number),
    Count = count(*)
from
    dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
    left join dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
        on DTS.documentnumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
    AND DTS.INTEGR_REC_GROUPREF is null

/**
 * Distinct documents in DTS but not FDM
 */
select
    DistinctDocNo = count(distinct DTS.documentNumber),
    Count = count(*)
from
    dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
    left join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
        on DTS.documentnumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF is null
    AND DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef

/**
 * Distinct documents common to FDM and DTS
 */
select
    DistinctDocNo = count(distinct DTS.documentNumber),
    Count = count(*)
from
    dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
    join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
        on DTS.documentnumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
    AND DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef

/**
 * Base document counts
 */
select System = 'DTS', DocumentCount = count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef union all
select System = 'FDM', DocumentCount = count(*) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef union all
select System = 'DTS (distinct DocNo)', DocumentCount = count(distinct documentNumber) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef union all
select System = 'FDM (distinct DocNo)', DocumentCount = count(distinct document_number) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef