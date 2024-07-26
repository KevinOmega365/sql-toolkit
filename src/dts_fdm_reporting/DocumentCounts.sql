declare @dts_valhall_groupRef uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
declare @fdm_PwpFenris_groupRef uniqueidentifier = '8770e32a-670b-499e-bb64-586b147019be'

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
    FDM.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef
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
    FDM.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef
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
    AND DTS.INTEGR_REC_GROUPREF = @dts_valhall_groupRef

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
    FDM.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef
    AND DTS.INTEGR_REC_GROUPREF = @dts_valhall_groupRef

/**
 * Base document counts
 */
select System = 'DTS', DocumentCount = count(*) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef union all
select System = 'FDM', DocumentCount = count(*) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef union all
select System = 'DTS (distinct DocNo)', DocumentCount = count(distinct documentNumber) from dbo.ltbl_Import_DTS_DCS_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef union all
select System = 'FDM (distinct DocNo)', DocumentCount = count(distinct document_number) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef