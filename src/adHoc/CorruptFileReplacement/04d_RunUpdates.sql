
BEGIN

    SET NOCOUNT ON;

    ---------------------------------------------------------------------------
    ------------------------------------------------------- Status Constants --
    ---------------------------------------------------------------------------

    DECLARE @ACTION_UPDATE_FILE AS NVARCHAR(50) = 'ACTION_UPDATE_FILE'
    DECLARE @UPDATE_FAILED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='UPDATE_FAILED')
    DECLARE @UPDATED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='UPDATED')

    ---------------------------------------------------------------------------

    DECLARE @CurrentPrimKey UNIQUEIDENTIFIER

    DECLARE @RowCount INT = 0;

    ---------------------------------------------------------------------------
    ------------------------------------- Replace Corrupt File with New File --
    ---------------------------------------------------------------------------

    DECLARE @DCS_RF_PrimKey UNIQUEIDENTIFIER

    ---------------------------------------------------------------------------

    WHILE EXISTS (
        SELECT *
        FROM dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I WITH (NOLOCK)
        WHERE
            INTEGR_REC_STATUS = @ACTION_UPDATE_FILE
    )
    BEGIN

         -- order does not matter here
        SELECT TOP 1 @CurrentPrimKey = PrimKey
        FROM dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I WITH (NOLOCK)
        WHERE
            INTEGR_REC_STATUS = @ACTION_UPDATE_FILE

        BEGIN TRY

            SET @RowCount = 0;
            -------------------------------------------------------------------

            -- 1) get the PrimKey for the file reference to remove
            SELECT @DCS_RF_PrimKey = DCS_RF.PrimKey
            FROM
                dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I WITH (NOLOCK)
                JOIN dbo.atbl_DCS_RevisionsFiles AS DCS_RF WITH (NOLOCK)
                    -- todo: base this on object_guid
                    on DCS_RF.Domain = I.DCS_Domain
                    AND DCS_RF.DocumentID = I.DCS_DocumentID
                    AND DCS_RF.RevisionItemNo = I.DCS_RevisionItemNo
                    AND DCS_RF.OriginalFilename = I.DCS_OriginalFilename
            WHERE
                I.DCS_FileRef <> DCS_RF.FileRef
                AND I.PrimKey = @CurrentPrimKey

            -- 2) delete the DCS file reference by primkey
            DELETE dbo.atbl_DCS_RevisionsFiles
            WHERE PrimKey = @DCS_RF_PrimKey

            -- 3) insert the new file reference
            INSERT INTO dbo.atbl_DCS_RevisionsFiles (
                Domain,
                DocumentID,
                RevisionItemNo,
                FileName,
                FileRef,
                Type,
                FileSize,
                SortOrder,
                OriginalFileName,
                Import_ExternalUniqueRef,
                FileDescription,
                CDL
            )
            SELECT
                RF.DCS_Domain,
                RF.DCS_DocumentID,
                RF.DCS_RevisionItemNo,
                RF.DCS_FileName,
                RF.DCS_FileRef,
                RF.DCS_Type,
                RF.DCS_FileSize,
                RF.DCS_SortOrder,
                RF.DCS_OriginalFileName,
                RF.DCS_Import_ExternalUniqueRef,
                RF.DCS_FileDescription,
                1
            FROM
                dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS RF WITH (NOLOCK)
            WHERE
                RF.PrimKey = @CurrentPrimKey

            -------------------------------------------------------------------
            SET @RowCount =  @@ROWCOUNT;

        END TRY
        BEGIN CATCH

            UPDATE I
                SET I.INTEGR_REC_STATUS = @UPDATE_FAILED,
                    I.INTEGR_REC_ERROR = ISNULL(I.INTEGR_REC_ERROR + ' ', '')
                        + 'FAILED: Replacing revision files from BMS for domain: '
                        + I.DCS_Domain
                        + '. ERROR:'
                        + ERROR_MESSAGE()
                FROM
                    dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I
                WHERE
                    I.PrimKey = @CurrentPrimKey

        END CATCH;

        -- Need to make sure row is actually updated.
        IF @RowCount > 0
        BEGIN
            UPDATE I
            SET I.INTEGR_REC_STATUS = @UPDATED
            FROM dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I
            WHERE
                I.PrimKey = @CurrentPrimKey
                AND I.INTEGR_REC_STATUS <> @UPDATE_FAILED
        END
        ELSE
        BEGIN
            -- This *should* not happen, which means it will.
            UPDATE I
            SET
                I.INTEGR_REC_STATUS = @UPDATE_FAILED,
                I.INTEGR_REC_ERROR = 'Internal logic error: record not updated'
            FROM dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS I
            WHERE
                I.PrimKey = @CurrentPrimKey
                AND I.INTEGR_REC_STATUS <> @UPDATE_FAILED
        END

    END

END