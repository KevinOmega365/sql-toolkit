CREATE OR ALTER PROCEDURE [dbo].[lstp_Import_DTS_DCS_InitiateRevisionApproval] (
    @GroupRef UNIQUEIDENTIFIER, -- Used to tag records and log entries with the PrimKey of the group (INTEGR_REC_GROUPREF)
    @TaskRef UNIQUEIDENTIFIER,  -- Used to tag records and log entries with the PrimKey of the current group-task
    @BatchRef UNIQUEIDENTIFIER -- Used to tag all records and log entries across a group execution run (INTEGR_REC_BATCHREF)
)

AS
BEGIN

    SET NOCOUNT ON;

    IF @BatchRef IS NULL
    BEGIN
        RAISERROR('Parameter BatchRef can not be null',18,1)
        RETURN
    END

    IF @GroupRef IS NULL
    BEGIN
        RAISERROR('Parameter GroupRef can not be null',18,1)
        RETURN
    END

    -------------------------------------------------------------------------------
    ---------------------------------------------------- constants and variables --
    -------------------------------------------------------------------------------

    DECLARE @ACTION_INSERT AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='ACTION_INSERT') -- Transition
    DECLARE @IGNORED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='IGNORED') -- Final
    DECLARE @IMPORTED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='IMPORTED_OK') -- Transition
    DECLARE @INSERT_FAILED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='INSERT_FAILED') -- Final
    DECLARE @INSERTED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='INSERTED') -- Final
    DECLARE @OUT_OF_SCOPE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='OUT_OF_SCOPE') -- Final
    DECLARE @VALIDATION_FAILED AS NVARCHAR(50) = (SELECT ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID = 'VALIDATION_FAILED') -- Final

    DECLARE @TraceBaseJson NVARCHAR(MAX) = '{ "action": [], "scope": [], "validation": [], "warning": [] }';
    DECLARE @TraceItem NVARCHAR(256);

    DECLARE @CurrentPrimKey UNIQUEIDENTIFIER
    DECLARE @RowCount INT = 0;
    -------------------------------------------------------------------------------
    ---------------------------------------------------------------------- stage --
    -------------------------------------------------------------------------------

    INSERT INTO dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems (
        INTEGR_REC_BATCHREF,
        INTEGR_REC_GROUPREF,
        DCS_Domain,
        DCS_DocumentID,
        DCS_RevisionItemNo,
        DCS_Receiver,
        DCS_ActionType,
        DCS_SequentialOrder,
        DCS_ApprovalDeadline,
        DCS_SystemGenerated,
        DCS_Selected
    )
    SELECT
        INTEGR_REC_BATCHREF,
        INTEGR_REC_GROUPREF,
        R.Domain,
        R.DocumentID,
        R.RevisionItemNo,
        DS.ReceiverPerson,
        DS.ActionType,
        DS.SequentialOrder,
        ApprovalDeadline = NULL, -- see transform
        SystemGenerated = 1,
        Selected = 0
    FROM
        dbo.ltbl_Import_DTS_DCS_Revisions AS IR WITH (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = IR.DCS_Domain
            AND R.DocumentID = IR.DCS_DocumentID
            AND R.Revision = IR.DCS_Revision
        JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
            ON DS.Domain = IR.DCS_Domain
            AND DS.DocumentID = IR.DCS_DocumentID
    WHERE
        DS.DistributionType = N'Approval'
        AND IR.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    -------------------------------------------------------------- transform --
    ---------------------------------------------------------------------------

    ------------------------------------------------------- ApprovalDeadline --
    UPDATE T
    SET
        DCS_ApprovalDeadline = [dbo].[afnc_DCS_GetDateDelayedByWorkdays] (
            T.DCS_Domain,
            GETUTCDATE(),
            ISNULL(Constants.DefaultApprovalDeadlineDays, 0),
            ISNULL(
                Contracts.WorkdaysCalendar,
                Constants.WorkdaysCalendar
            )
        )
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems T WITH (NOLOCK)
        INNER JOIN dbo.atbl_DCS_Constants AS Constants WITH (NOLOCK)
            ON Constants.Domain = T.DCS_Domain
        LEFT JOIN dbo.atbl_DCS_Contracts AS Contracts WITH (NOLOCK)
            ON Contracts.Domain = T.DCS_Domain
    WHERE
        T.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ------------------------------------------------------------- validation --
    ---------------------------------------------------------------------------

    ---------------------------------------------------------------- IsDraft --
    SET
        @TraceItem = 'Revision is not set to draft'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.scope',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @OUT_OF_SCOPE
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
    WHERE
        R.IsDraft <> 1
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ------------------------------------------------- Automatic distribution --
    SET
        @TraceItem = 'Automatic distribution is not configured'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.validation',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @VALIDATION_FAILED
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
        JOIN dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
            ON R.Domain = R.Domain
            AND R.DocumentID = R.DocumentID
        INNER JOIN dbo.atbl_DCS_Settings AS S WITH (NOLOCK)
            ON S.Domain = D.Domain
        LEFT JOIN dbo.atbl_DCS_Contracts AS C WITH (NOLOCK)
            ON C.Domain = D.Domain
            AND C.ContractNo = ISNULL(R.ProjectContractNo, D.ContractNo)
    WHERE
        (
            S.AutoPopulateApprovalTrayOnNewRev = 0 -- non-null: OK
                AND C.AutomaticallyDistributeSubmittals = 0 -- non-null: OK
        )
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    -------------------------------------------------------- RequireApproval --
    SET
        @TraceItem = 'Approval is not required'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.scope',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @OUT_OF_SCOPE
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
        JOIN dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
            ON R.Domain = R.Domain
            AND R.DocumentID = R.DocumentID
        INNER JOIN dbo.atbl_DCS_DocumentTypesSteps AS DTS WITH (NOLOCK)
            ON DTS.Domain = D.Domain
            AND DTS.PlantID = D.PlantID
            AND DTS.DocumentType = D.DocumentType
            AND DTS.Step = R.Step
    WHERE
        DTS.RequireApproval <> 1 -- todo: handle nulls if they can exist
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    -------------------------------------------------- EnableApprovalProcess --
    SET
        @TraceItem = 'Approval is not process enabled'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.validation',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @VALIDATION_FAILED
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        INNER JOIN dbo.atbl_DCS_Settings AS S WITH (NOLOCK)
            ON S.Domain = T.DCS_Domain
    WHERE
        S.EnableApprovalProcess <> 1 -- todo: handle nulls if they can exist
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    --------------------------------------- RequireDistinctDistributionSetup --
    SET
        @TraceItem = 'Missing Required Distinct Distribution Setup'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.validation',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @VALIDATION_FAILED
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
        JOIN dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
            ON D.Domain = R.Domain
            AND D.DocumentID = R.DocumentID
        JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
            ON DS.Domain = D.Domain
            AND DS.DocumentID = D.DocumentID
            AND DS.DistributionType = N'Approval'
        JOIN dbo.atbl_DCS_DocumentTypesSteps AS DTS WITH (NOLOCK)
            ON DTS.Domain = D.Domain
            AND DTS.PlantID = D.PlantID
            AND DTS.DocumentType = D.DocumentType
            AND DTS.Step = R.Step
    WHERE
        NOT EXISTS ( -- match DistributionSetup against Revision and Step if required
            SELECT
                DS.Step,
                DS.ProjectPlantID,
                DS.ProjectID,
                DS.ProjectContractNo
            INTERSECT
            SELECT
                (
                    CASE
                        WHEN DTS.RequireDistinctDistributionSetup = 1 THEN R.Step
                        ELSE NULL
                    END
                ),
                R.ProjectPlantID,
                R.ProjectID,
                R.ProjectContractNo
        )
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ------------------------- RequireDCCValidationBeforeImportToMainRegister --
    SET
        @TraceItem = 'DCC validation required before import to main register'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.scope',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @OUT_OF_SCOPE
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
        JOIN dbo.atbl_DCS_Documents AS D ON D.Domain = R.Domain
            AND D.DocumentID = R.DocumentID
        LEFT JOIN dbo.atbl_DCS_Contracts AS C WITH (NOLOCK)
            ON C.Domain = D.Domain
            AND C.ContractNo = ISNULL(R.ProjectContractNo, D.ContractNo)
    WHERE
        ISNULL(
            C.RequireDCCValidationBeforeImportToMainRegister,
            0
        ) = 1
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ------------------------------- Exlude receiver when author and verifier --
    SET
        @TraceItem = 'Exlude receiver when author and verifier'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.scope',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @OUT_OF_SCOPE
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
        JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = T.DCS_Domain
            AND R.DocumentID = T.DCS_DocumentID
            AND R.RevisionItemNo = T.DCS_RevisionItemNo
        JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
            ON DS.Domain = T.DCS_Domain
            AND DS.DocumentID = T.DCS_DocumentID
    WHERE
        EXISTS (
            SELECT
                * --exlude receiver where he is an author and his action is Verifier
            FROM
                dbo.atbl_ProjectSetup_Persons AS P WITH (NOLOCK)
                INNER JOIN dbo.atbl_DCS_ActionTypes AT WITH (NOLOCK)
                    ON AT.ActionType = DS.ActionType
            WHERE
                P.PersonID = DS.ReceiverPerson
                    AND P.[Login] = R.CreatedBy
                    AND AT.SystemActionType = N'Verifier'
        )
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    --------------------------- Receiver does not have sufficient permission --
    SET
        @TraceItem = 'User is expired or is not a teammember or does not have sufficient permissions'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.validation',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @VALIDATION_FAILED
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
    WHERE
        NOT EXISTS (
            SELECT
                *
            FROM
                dbo.atbl_ProjectSetup_Persons AS PT WITH (NOLOCK)
                INNER JOIN dbo.stbl_System_Users AS UT WITH (NOLOCK)
                    ON UT.[Login] = PT.[Login]
                    AND UT.UserExpired = 0
                INNER JOIN dbo.atbl_ProjectSetup_TeamMembers TMT WITH (NOLOCK)
                    ON TMT.Domain = T.DCS_Domain
                    AND TMT.PersonID = PT.PersonID
                    AND TMT.Expired = 0
            WHERE
                TMT.Domain = T.DCS_Domain
                    AND PT.PersonID = T.DCS_Receiver
                    AND PT.Expired = 0
                    AND EXISTS (
                    SELECT
                        *
                    FROM
                        dbo.stbl_System_RolesMembersDomains AS RM WITH (NOLOCK)
                        INNER JOIN dbo.stbl_System_RolesCapabilities AS RC WITH (NOLOCK)
                            ON RC.RoleID = RM.RoleID
                    WHERE
                        RM.Domain = T.DCS_Domain
                            AND RM.[Login] = UT.[Login]
                            AND RC.CapabilityCode IN (
                            N'dcs_approval_can_approve_documents',
                            N'dcs_approval_can_verify_documents'
                        )
                )
        )
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ----------------------------------------------------------------- action --
    ---------------------------------------------------------------------------

    ----------------------------------------------- Receiver already in tray --
    SET
        @TraceItem = 'Receiver already in tray for this document revision'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @IGNORED
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
    WHERE
        EXISTS (
            SELECT
                *
            FROM
                dbo.atbl_DCS_ApprovalTray AS RT WITH (NOLOCK)
            WHERE
                RT.Domain = DCS_Domain
                    AND RT.DocumentID = DCS_DocumentID
                    AND RT.Receiver = DCS_Receiver
                    AND RT.RevisionItemNo = DCS_RevisionItemNo
        )
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------- All valid and not ignored --
    SET
        @TraceItem = 'All valid and not ignored'
    UPDATE T
    SET
        INTEGR_REC_TRACE = JSON_MODIFY(
            ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
            'append $.action',
            @TraceItem
        ),
        INTEGR_REC_STATUS = @ACTION_INSERT
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS T with (NOLOCK)
    WHERE
        T.INTEGR_REC_STATUS = @IMPORTED_OK
        AND T.INTEGR_REC_BATCHREF = @BatchRef

    ---------------------------------------------------------------------------
    ------------------------------------------------------------------ merge --
    ---------------------------------------------------------------------------

    WHILE EXISTS (
        SELECT *
        FROM dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS I WITH (NOLOCK)
        WHERE
            INTEGR_REC_STATUS = @ACTION_INSERT
            AND I.INTEGR_REC_BATCHREF = @BatchRef
    )
    BEGIN

        SELECT TOP 1 -- order doesn't matter here
            @CurrentPrimKey = I.PrimKey
        FROM
            dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems I WITH (NOLOCK)
        WHERE
            INTEGR_REC_STATUS = @ACTION_INSERT
            AND I.INTEGR_REC_BATCHREF = @BatchRef

        BEGIN TRY

            SET @RowCount = 0;

            -------------------------------------------------------------------

            INSERT INTO dbo.atbl_DCS_ApprovalTray
            (
                Domain,
                DocumentID,
                RevisionItemNo,
                Receiver,
                ActionType,
                SequentialOrder,
                ApprovalDeadline,
                SystemGenerated,
                Selected
            )
            SELECT
                DCS_Domain,
                DCS_DocumentID,
                DCS_RevisionItemNo,
                DCS_Receiver,
                DCS_ActionType,
                DCS_SequentialOrder,
                DCS_ApprovalDeadline,
                DCS_SystemGenerated,
                DCS_Selected
            FROM
                dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems T WITH (NOLOCK)
            WHERE
                PrimKey = @CurrentPrimKey

            -------------------------------------------------------------------

            SET @RowCount = @@ROWCOUNT;

        END TRY
        BEGIN CATCH
        
            UPDATE I
            SET
                I.INTEGR_REC_STATUS = @INSERT_FAILED,
                I.INTEGR_REC_ERROR =
                    ISNULL(I.INTEGR_REC_ERROR + ' ', '')
                    + 'FAILED: inserting tray item: '
                    + I.DCS_Domain
                    + '. ERROR:'
                    + ERROR_MESSAGE()
            FROM
                dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS I
            WHERE
                I.PrimKey = @CurrentPrimKey

        END CATCH;

        -- Need to make sure row is actually updated.
        IF @RowCount > 0
        BEGIN
            UPDATE I
            SET I.INTEGR_REC_STATUS = @INSERTED
            FROM dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS I
            WHERE
                I.PrimKey = @CurrentPrimKey
                AND I.INTEGR_REC_STATUS <> @INSERT_FAILED
                AND I.INTEGR_REC_BATCHREF = @BatchRef
        END
        ELSE
        BEGIN
            -- This *should* not happen, which means it will.
            UPDATE I
            SET
                I.INTEGR_REC_STATUS = @INSERT_FAILED,
                I.INTEGR_REC_ERROR = 'Internal logic error: record not updated'
            FROM
                dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS I
            WHERE
                I.PrimKey = @CurrentPrimKey
                AND I.INTEGR_REC_STATUS <> @INSERT_FAILED
                AND I.INTEGR_REC_BATCHREF = @BatchRef
        END

    END

    ---------------------------------------------------------------------------
    ----------------------------------------------------------------- report --
    ---------------------------------------------------------------------------

    SELECT 'atbl_DCS_ApprovalTray' AS TableName, 
        (
            SELECT COUNT(*)
            FROM dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems AS I WITH (NOLOCK)
            WHERE
            I.INTEGR_REC_BATCHREF = @BatchRef
            AND I.INTEGR_REC_STATUS = @INSERTED
        ) AS InsertedRowsCount, 
        0 AS UpdatedRowsCount, 
        0 AS DeletedRowsCount, 
        '' AS ErrorMsg; 

    ---------------------------------------------------------------------------

END