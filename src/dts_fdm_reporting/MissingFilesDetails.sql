/*
 *  details on the missing files
 */

declare @dts_valhall_groupRef uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
declare @fdm_PwpFenris_groupRef uniqueidentifier = '8770e32a-670b-499e-bb64-586b147019be'

drop table if exists #CommonDocuments
drop table if exists #CommonDocumentsRevisions

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

/**
 * Status and trace aggregates for files in FDM but not DTS
 */
select distinct -- top 50
    -- count(*)
    -- , count(distinct RF.PrimKey)

    Domain = RF.DCS_Domain,
    DocumentID = RF.document_number,
    Revision = RF.revision,
    OriginalFilename = RF.original_filename,
    FileCreatedBy = PimsRevisionsFiles.CreatedBy

from 
    -- common documents and revisions from above
    #CommonDocumentsRevisions CommonDocRev
    -- revisions files from FDM
    join dbo.ltbl_Import_ProArc_RevisionFiles AS RF WITH (NOLOCK)
        on RF.document_number = CommonDocRev.documentNumber
        and RF.revision = CommonDocRev.revision
    -- files from FDM
    JOIN dbo.ltbl_Import_ProArc_Files AS F WITH (NOLOCK)
        ON F.FileID = RF.Cdf_file_id
        AND F.proarc_file_checksum = RF.proarc_file_checksum
    -- System files: Pims filestore references
    JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
        ON SF.PrimKey = F.FileRef

    join (
        SELECT
            DRF.Domain,
            DRF.DocumentID,
            DR.Revision,
            DRF_SF.CRC,
            DRF.Import_ExternalUniqueRef,
            DRF.CreatedBy
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
                ON DR.Domain = DRF.Domain
                AND DR.DocumentID = DRF.DocumentID
                AND DR.RevisionItemNo = DRF.RevisionItemNo
            INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
                ON DRF_SF.PrimKey = DRF.FileRef
    ) PimsRevisionsFiles
            ON PimsRevisionsFiles.Domain = RF.DCS_Domain
            AND PimsRevisionsFiles.DocumentID = RF.Document_number
            AND PimsRevisionsFiles.Revision = RF.Revision
            AND (
                PimsRevisionsFiles.CRC = SF.CRC
                OR PimsRevisionsFiles.Import_ExternalUniqueRef = 'ProArc:'+RF.Proarc_file_primary_key
            )

    -- DTS revisions files import
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles DTS with (nolock)
        on DTS.documentNumber = RF.document_number
        and DTS.revision = RF.revision
        and DTS.originalFilename = RF.original_filename

-- logic for trace.action === File already exists
WHERE
    EXISTS (
        SELECT *
        FROM
            dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
            INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
                ON DR.Domain = DRF.Domain
                AND DR.DocumentID = DRF.DocumentID
                AND DR.RevisionItemNo = DRF.RevisionItemNo
            INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
                ON DRF_SF.PrimKey = DRF.FileRef
        WHERE
            DRF.Domain = RF.DCS_Domain
            AND DRF.DocumentID = RF.Document_number
            AND DR.Revision = RF.Revision
            AND (
                DRF_SF.CRC = SF.CRC
                OR DRF.Import_ExternalUniqueRef = 'ProArc:'+RF.Proarc_file_primary_key
            )
    )

    and DTS.INTEGR_REC_GROUPREF is null
    and RF.INTEGR_REC_STATUS = 'IGNORED' -- same as exists clause
    and RF.INTEGR_REC_TRACE like '%"File already exists"%' -- same as exists clause
    and RF.INTEGR_REC_GROUPREF = @fdm_PwpFenris_groupRef

order by -- newid()
    Domain,
    DocumentID,
    Revision,
    OriginalFilename