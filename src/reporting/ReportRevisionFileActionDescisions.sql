
declare @BatchRef uniqueidentifier = '06a5bc6d-6f97-461f-9a54-d200dc33670e'

drop table if exists #filesInclusionRuleTrace

select
    Cdf_file_id,
    CreatedBy,
    DCS_Domain,
    Document_number,
    File_comment,
    File_sequence_number,
    INTEGR_REC_BATCHREF,
    INTEGR_REC_STATUS,
    PreviousStatus = INTEGR_REC_STATUS,
    INTEGR_REC_TRACE,
    PreviousTrace = INTEGR_REC_TRACE,
    IsDeleted,
    Proarc_document_primary_key,
    proarc_file_checksum,
    Proarc_file_primary_key,
    Revision,
    File_type,
    original_filename
into
    #filesInclusionRules
from
    dbo.ltbl_Import_ProArc_RevisionFiles with (nolock)
where
    document_number = 'FPQ-AKSO-S-XB-71001-01'

update #filesInclusionRules
set
    INTEGR_REC_TRACE = ''

-- select * from #filesInclusionRules -- debug

BEGIN

    SET NOCOUNT ON;

    DECLARE @ACTION_DELETE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='ACTION_DELETE')
    DECLARE @ACTION_INSERT AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='ACTION_INSERT')
    DECLARE @ACTION_UPDATE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='ACTION_UPDATE')
    DECLARE @IGNORED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='IGNORED')
    DECLARE @VALIDATED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='VALIDATED_OK')

    DECLARE @TraceBaseJson nvarchar(max) = '{ "action": [], "scope": [], "validation": [], "warning": [] }';
    DECLARE @TraceItem nvarchar(128);

    ---------------------------------------------------------------------------
    -------------------------------------- Revision Files: Insert Candidates --
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------- Exclude --

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- Exclude --
    SET @TraceItem = '{ "include": false, "rule": "File already exists" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
        INNER JOIN dbo.ltbl_Import_ProArc_Files AS F WITH (NOLOCK)
        ON F.FileID = RF.Cdf_file_id
        AND F.proarc_file_checksum = RF.proarc_file_checksum
        INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
            ON SF.PrimKey = F.FileRef
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

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- Exclude --
    SET @TraceItem = '{ "include": false, "rule": "No Valid Revision Found" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
        LEFT JOIN dbo.ltbl_Import_ProArc_Revisions AS R WITH  (NOLOCK)
            ON R.DCS_Domain = RF.DCS_Domain
            AND R.Document_number = RF.Document_number
            AND R.Revision = RF.Revision
            AND R.Proarc_document_primary_key = RF.Proarc_document_primary_key
            AND R.INTEGR_REC_BATCHREF = RF.INTEGR_REC_BATCHREF
    WHERE
        R.INTEGR_REC_STATUS NOT IN (@IGNORED,@ACTION_INSERT,@ACTION_UPDATE) -- Post validation
        AND RF.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------

    ---------------------------------------------------------------- INCLUDE --

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- INCLUDE --
    SET @TraceItem = '{ "include": true, "rule": "File comment begins with #" }'
    UPDATE RF
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
    WHERE
        RF.File_comment LIKE '#%'
        AND RF.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- INCLUDE --
    SET @TraceItem = '{ "include": true, "rule": "File is a PDF with minimal sequence number" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
        INNER JOIN dbo.ltbl_Import_ProArc_Files AS F WITH (NOLOCK)
            ON F.FileID = RF.Cdf_file_id
            AND F.proarc_file_checksum = RF.proarc_file_checksum
    WHERE
        RF.File_sequence_number = (
            SELECT
                MIN(CAST(File_sequence_number AS INT)) AS SequenceNumber
            FROM
                #filesInclusionRules AS MinSequeceNumberFile WITH (NOLOCK)
            WHERE
                MinSequeceNumberFile.Document_number = RF.Document_number
                AND MinSequeceNumberFile.Revision = RF.Revision
                AND MinSequeceNumberFile.Proarc_document_primary_key = RF.Proarc_document_primary_key
                AND ISNULL(MinSequeceNumberFile.IsDeleted, '') <> 'True'
                AND MinSequeceNumberFile.File_type = 'pdf'
                AND MinSequeceNumberFile.INTEGR_REC_BATCHREF = RF.INTEGR_REC_BATCHREF
        )
        AND F.Extension = 'pdf'
        AND RF.INTEGR_REC_BATCHREF = @BatchRef

    ----------------------------------------------------- Supplier Documents --

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- INCLUDE --
    SET @TraceItem = '{ "include": true, "rule": "Supplier document with ORIGINAL as comment" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
        LEFT JOIN dbo.ltbl_Import_ProArc_Revisions AS R WITH  (NOLOCK)
            ON R.DCS_Domain = RF.DCS_Domain
            AND R.Document_number = RF.Document_number
            AND R.Revision = RF.Revision
            AND R.Proarc_document_primary_key = RF.Proarc_document_primary_key
            AND R.INTEGR_REC_BATCHREF = RF.INTEGR_REC_BATCHREF
        LEFT JOIN dbo.ltbl_Import_ProArc_Documents AS D WITH (NOLOCK)
            ON D.DCS_Domain = R.DCS_Domain
            AND D.Document_number = R.Document_number
            AND D.Proarc_document_primary_key = R.Proarc_document_primary_key
            AND D.INTEGR_REC_BATCHREF = R.INTEGR_REC_BATCHREF
    WHERE
        D.document_group = 'SUP'
        AND RF.File_comment = 'ORIGINAL'
        AND RF.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- INCLUDE --
    SET @TraceItem = '{ "include": true, "rule": "Supplier document with MARK-UP as comment and status value set" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
        LEFT JOIN dbo.ltbl_Import_ProArc_Revisions AS R WITH  (NOLOCK)
            ON R.DCS_Domain = RF.DCS_Domain
            AND R.Document_number = RF.Document_number
            AND R.Revision = RF.Revision
            AND R.Proarc_document_primary_key = RF.Proarc_document_primary_key
            AND R.INTEGR_REC_BATCHREF = RF.INTEGR_REC_BATCHREF
        LEFT JOIN dbo.ltbl_Import_ProArc_Documents AS D WITH (NOLOCK)
            ON D.DCS_Domain = R.DCS_Domain
            AND D.Document_number = R.Document_number
            AND D.Proarc_document_primary_key = R.Proarc_document_primary_key
            AND D.INTEGR_REC_BATCHREF = R.INTEGR_REC_BATCHREF
    WHERE
        D.document_group = 'SUP'
        AND RF.File_comment = 'MARK-UP'
        AND ISNULL(R.[Status],'') <> ''
        AND RF.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------- Exclude --
    SET @TraceItem = '{ "include": false, "rule": "No Inclusion Rule Matched" }'
    UPDATE RF
    SET
        RF.INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(RF.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            JSON_QUERY(@TraceItem)
        )
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
    WHERE

        (
            ISNULL(INTEGR_REC_TRACE, '') = ''
            OR
            NOT EXISTS (
                SELECT *
                FROM OPENJSON(RF.INTEGR_REC_TRACE, '$.action') RecordTrace
                WHERE JSON_VALUE(RecordTrace.value, '$.include') = 'true'
            )
        )
        AND INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ------------------------------------ Revision Files: Set action / status --
    ---------------------------------------------------------------------------

    /**
     * First set $.include === false to @IGNORED
     */
    UPDATE RF
    SET
        RF.INTEGR_REC_STATUS = @IGNORED
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
    WHERE
        EXISTS (
            SELECT *
            FROM OPENJSON(RF.INTEGR_REC_TRACE, '$.action') RecordTrace
            WHERE JSON_VALUE(RecordTrace.value, '$.include') = 'false'
        )
        AND INTEGR_REC_BATCHREF = @BatchRef
        AND RF.INTEGR_REC_STATUS = @VALIDATED_OK

    /**
     * Second set $.include === true (and no false's) to @ACTION_INSERT
     */
    UPDATE RF
    SET
        RF.INTEGR_REC_STATUS = @ACTION_INSERT
    FROM
        #filesInclusionRules AS RF WITH (NOLOCK)
    WHERE
        EXISTS (
            SELECT *
            FROM OPENJSON(RF.INTEGR_REC_TRACE, '$.action') RecordTrace
            WHERE JSON_VALUE(RecordTrace.value, '$.include') = 'true'
        )
        AND NOT EXISTS (
            SELECT *
            FROM OPENJSON(RF.INTEGR_REC_TRACE, '$.action') RecordTrace
            WHERE JSON_VALUE(RecordTrace.value, '$.include') = 'false'
        )
        AND INTEGR_REC_BATCHREF = @BatchRef
        AND RF.INTEGR_REC_STATUS = @VALIDATED_OK

END

select
    Domain = DCS_Domain,
    DocumentID = Document_number,
    Revision,
    OrginalFilename = original_filename,
    Comment = File_comment,
    FileType = File_type,
    SeqNo = File_sequence_number,
    PreviousStatus,
    PreviousTrace,
    Status = INTEGR_REC_STATUS,
    Trace = INTEGR_REC_TRACE
from
    #filesInclusionRules
order by
    DCS_Domain,
    Document_number,
    Revision