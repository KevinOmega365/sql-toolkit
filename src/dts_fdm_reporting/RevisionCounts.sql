declare @dts_valhall_groupRef uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
declare @fdm_PwpFenris_groupRef uniqueidentifier = '8770e32a-670b-499e-bb64-586b147019be'

drop table if exists #CommonDocuments

/**
 * Distinct documents common to FDM and DTS
 */
select distinct
    DTS.documentNumber
into
    #CommonDocuments
from
    dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
    join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
        on DTS.documentNumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef
    AND DTS.INTEGR_REC_GROUPREF = @dts_valhall_groupRef

/**
 * List distinct Revisions in FDM but not DTS
 */
select distinct
    FDM.document_number,
    FdmDocs.title,
    FDM.revision,
    FDM.INTEGR_REC_STATUS,
    FDM.INTEGR_REC_TRACE
from
    #CommonDocuments CommonDocuments
    join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
        on FDM.document_number = CommonDocuments.documentNumber
    left join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
        on DTS.documentNumber = FDM.document_number
        and DTS.revision = FDM.revision
    join dbo.ltbl_Import_ProArc_Documents FdmDocs with (nolock)
        on FdmDocs.document_number = FDM.document_number
where
    DTS.INTEGR_REC_GROUPREF is null
    and FDM.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef
order by
    FDM.document_number,
    FdmDocs.title,
    FDM.revision

/**
 * Distinct Revisions in FDM but not DTS
 */
select
    RevisionCount = count(*)
from
    (
        select distinct
            FDM.document_number,
            FDM.revision
        from
            #CommonDocuments CommonDocuments
            join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
                on FDM.document_number = CommonDocuments.documentNumber
            join dbo.ltbl_Import_ProArc_Documents FdmDocs with (nolock)
                on FdmDocs.document_number = FDM.document_number
            left join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
                on DTS.documentNumber = FDM.document_number
                and DTS.revision = FDM.revision
        where
            DTS.INTEGR_REC_GROUPREF is null
    ) T

/**
 * Revisions in DTS but not FDM
 */
select
    RevisionCount = count(*)
from
    #CommonDocuments CommonDocuments
    join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
        on DTS.documentNumber = CommonDocuments.documentNumber
    left join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
        on FDM.document_number = DTS.documentNumber
        and FDM.revision = DTS.revision
where
    FDM.PrimKey is null

/**
 * Documents and revisions common to DTS and FDM
 */
select
    RevisionCount = count(*)
from
    #CommonDocuments CommonDocuments
    join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
        on DTS.documentNumber = CommonDocuments.documentNumber
    join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
        on FDM.document_number = DTS.documentNumber
        and FDM.revision = DTS.revision
    join dbo.ltbl_Import_ProArc_Documents FdmDocs with (nolock)
        on FdmDocs.document_number = FDM.document_number

/**
 * Base document counts
 */
select System = 'DTS', Count = count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef union all
select System = 'FDM', Count = count(*) from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef union all
select System = 'DTS (distinct DocNo, revision)', Count = (select count(*) from (select distinct documentNumber, revision from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock) where INTEGR_REC_GROUPREF = @dts_valhall_groupRef)T) union all
select System = 'FDM (distinct DocNo, revision)', Count = (select count(*) from (select distinct document_number, revision from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef)T)