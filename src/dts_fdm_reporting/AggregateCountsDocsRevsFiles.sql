declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'

drop table if exists #CommonDocuments
drop table if exists #CommonDocumentsRevisions

-------------------------------------------------------------------------------
------------------------------------------------------------- Working Tables --
-------------------------------------------------------------------------------

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
 * Documents and revisions common to DTS and FDM
 */
select distinct
    DTS.documentNumber
    , DTS.revision
into
    #CommonDocumentsRevisions
from
    #CommonDocuments CommonDocuments
    join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
        on DTS.documentNumber = CommonDocuments.documentNumber
    join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
        on FDM.document_number = DTS.documentNumber
        and FDM.revision = DTS.revision
    join dbo.ltbl_Import_ProArc_Documents FdmDocs with (nolock)
        on FdmDocs.document_number = FDM.document_number

-------------------------------------------------------------------------------
-------------------------------------------------------------------- Queries --
-------------------------------------------------------------------------------

/**
 *  Status and trace aggregates for documents in FDM but not DTS
 */
select
    Count = count(*)
    , FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
from
    dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
    left join dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
        on DTS.documentnumber = FDM.document_number
where
    FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
    AND DTS.INTEGR_REC_GROUPREF is null
group by
    FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
order by
    count(*) desc

/**
 * Status and trace aggregates for revisions in FDM but not DTS
 */
select distinct
    Count = count(*)
    , FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
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
group by
    FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
order by
    count(*) desc

/**
 * Status and trace aggregates for files in FDM but not DTS
 */
select
    Count = count(*)
    , FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
from 
    #CommonDocumentsRevisions CommonDocRev
    join dbo.ltbl_Import_ProArc_RevisionFiles FDM with (nolock)
        on FDM.document_number = CommonDocRev.documentNumber
        and FDM.revision = CommonDocRev.revision
    join dbo.ltbl_Import_ProArc_Documents FdmDocs with (nolock)
        on FdmDocs.document_number = FDM.document_number
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles DTS with (nolock)
        on DTS.documentNumber = FDM.document_number
        and DTS.revision = FDM.revision
        and DTS.originalFilename = FDM.original_filename
where
    DTS.INTEGR_REC_GROUPREF is null
group by
    FDM.INTEGR_REC_STATUS
    , FDM.INTEGR_REC_TRACE
order by
    count(*) desc