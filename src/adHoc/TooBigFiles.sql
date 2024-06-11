/**
 * PWP Fenris files that are too big
 */
SELECT
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock)
        where S.PrimKey = RF.INTEGR_REC_GROUPREF
    ),
    F.[Filename] AS FileTableFilename,
    F.FileID AS FileTableFileID,
    F.MD5Hash,
    RF.cdf_file_id,
    RF.proarc_document_primary_key,
    RF.proarc_file_checksum,
    RF.proarc_project_id,
    RF.proarc_revision_id,
    RF.revision,
    RF.filename
FROM dbo.ltbl_Import_ProArc_RevisionFiles AS RF WITH (NOLOCK)
LEFT JOIN dbo.ltbl_Import_ProArc_Files AS F WITH (NOLOCK)
    ON F.FileID = RF.cdf_file_id
    AND F.proarc_file_checksum = RF.proarc_file_checksum
WHERE
    F.PrimKey IS NULL
    AND RF.IsDeleted = 'false'
    AND (
        RF.File_type = 'PDF'    -- 26.11.2021 Decided that we're only interested in PDF files. Further filtering happens in procedure.
        OR RF.File_comment LIKE '#%' -- 13.01.2022 Decided that we also include files where comment starts #
        OR RF.File_Comment IN ('MARK-UP', 'ORIGINAL') -- Required Comment for Supplier Documents
    )
    AND RF.INTEGR_REC_GROUPREF = '8770e32a-670b-499e-bb64-586b147019be'

    -- todo: remove this
    AND len(RF.file_size) > 9 -- really big files over 999 999 999 bytes

/**
 * DTS_DCS
 */
SELECT
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups as S with (nolock)
        where S.PrimKey = RevisionsFiles.INTEGR_REC_GROUPREF
    ),
    RevisionsFiles.md5hash,
    RevisionsFiles.object_guid,
    originalFilename = COALESCE(
        RevisionsFiles.originalFilename,
        RevisionsFiles.fileName,
        CAST(RevisionsFiles.object_guid AS CHAR(36))
    ),
    RevisionsFiles.INTEGR_REC_BATCHREF
FROM
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RevisionsFiles WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Files AS Files WITH (NOLOCK)
        ON Files.object_guid = RevisionsFiles.object_guid
WHERE
    Files.PrimKey IS NULL

    -- todo: remove this
    AND len(RevisionsFiles.fileSize) > 9 -- really big files over 999 999 999 bytes