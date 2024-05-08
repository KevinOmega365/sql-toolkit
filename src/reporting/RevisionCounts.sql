declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'

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
    FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
    AND DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef

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
    and FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
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
select System = 'DTS', Count = count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef union all
select System = 'FDM', Count = count(*) from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef union all
select System = 'DTS (distinct DocNo, revision)', Count = (select count(*) from (select distinct documentNumber, revision from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef)T) union all
select System = 'FDM (distinct DocNo, revision)', Count = (select count(*) from (select distinct document_number, revision from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef)T)