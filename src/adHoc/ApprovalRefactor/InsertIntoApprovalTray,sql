-- INSERT INTO dbo.atbl_DCS_ApprovalTray
-- (
--    Domain,
--    DocumentID,
--    RevisionItemNo,
--    Receiver,
--    ActionType,
--    SequentialOrder,
--    ApprovalDeadline,
--    SystemGenerated,
--    Selected
-- )
SELECT DISTINCT
    T.Domain,
    T.DocumentID,
    T.RevisionItemNo,
    DS.ReceiverPerson,
    DS.ActionType,
    DS.SequentialOrder,
    [dbo].[afnc_DCS_GetDateDelayedByWorkdays] (
        T.Domain,
        GETUTCDATE(),
        ISNULL(Co.DefaultApprovalDeadlineDays, 0),
        ISNULL(C.WorkdaysCalendar, Co.WorkdaysCalendar)
    ) AS ApprovalDeadline,
    1 AS SystemGenerated,
    0 AS Selected
FROM
    dbo.atbx_DCS_ContractorInterface_DocumentsRevisionsFiles AS T -- Erstatt med tabell som har Domain, DocumentID, Primkey, og RevisionItemNo for revisjonen som skal sendes ut.
    INNER JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
      ON DS.Domain = T.Domain
      AND DS.DocumentID = T.DocumentID
      AND DS.DistributionType = N'Approval'
    --INNER JOIN #SP_temp_Revisions AS T ON T.Domain = RF.Domain AND T.DocumentID = RF.DocumentID
    INNER JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
      ON R.Domain = T.Domain
      AND R.PrimKey = T.PrimKey
    INNER JOIN dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
      ON D.Domain = DS.Domain
      AND D.DocumentID = DS.DocumentID
    INNER JOIN dbo.atbl_DCS_DocumentTypesSteps AS DTS WITH (NOLOCK)
      ON DTS.Domain = D.Domain
      AND DTS.PlantID = D.PlantID
      AND DTS.DocumentType = D.DocumentType
      AND DTS.Step = R.Step
    INNER JOIN dbo.atbl_DCS_Settings AS S WITH (NOLOCK)
      ON S.Domain = T.Domain
    INNER JOIN dbo.atbl_DCS_Constants AS Co WITH (NOLOCK)
      ON Co.Domain = T.Domain
    LEFT JOIN dbo.atbl_DCS_Contracts AS C WITH (NOLOCK)
      ON C.Domain = D.Domain
      AND C.ContractNo = ISNULL(R.ProjectContractNo, D.ContractNo)
    OUTER APPLY (
        SELECT
            CASE
                WHEN DTS.RequireDistinctDistributionSetup = 1
                THEN R.Step
                ELSE NULL
            END AS Step
    ) DDS
WHERE
    R.IsDraft = 1
    --AND RF.ValidationError IS NULL
    AND (
        S.AutoPopulateApprovalTrayOnNewRev = 1
        OR C.AutomaticallyDistributeSubmittals = 1
    )
    AND DTS.RequireApproval = 1
    AND S.EnableApprovalProcess = 1
    AND EXISTS (
        SELECT
            DS.Step,
            DS.ProjectPlantID,
            DS.ProjectID,
            DS.ProjectContractNo
        INTERSECT
        SELECT
            DDS.Step,
            R.ProjectPlantID,
            R.ProjectID,
            R.ProjectContractNo
    )
    AND ISNULL(
        C.RequireDCCValidationBeforeImportToMainRegister,
        0
    ) = 0
    AND NOT EXISTS (
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
    AND NOT EXISTS (
        SELECT
            *
        FROM
            dbo.atbl_DCS_ApprovalTray AS RT WITH (NOLOCK)
        WHERE
            RT.Domain = T.Domain
            AND RT.DocumentID = T.DocumentID
            AND RT.Receiver = DS.ReceiverPerson
            AND RT.RevisionItemNo = R.RevisionItemNo
    )
    AND EXISTS (
        SELECT
            *
        FROM
            dbo.atbl_ProjectSetup_Persons AS PT WITH (NOLOCK)
            INNER JOIN dbo.stbl_System_Users AS UT WITH (NOLOCK)
               ON UT.[Login] = PT.[Login]
               AND UT.UserExpired = 0
            INNER JOIN dbo.atbl_ProjectSetup_TeamMembers TMT WITH (NOLOCK)
               ON TMT.Domain = D.Domain
               AND TMT.PersonID = PT.PersonID
               AND TMT.Expired = 0
        WHERE
            TMT.Domain = DS.Domain
            AND PT.PersonID = DS.ReceiverPerson
            AND PT.Expired = 0
            AND EXISTS (
                SELECT
                    *
                FROM
                    dbo.stbl_System_RolesMembersDomains AS RM WITH (NOLOCK)
                    INNER JOIN dbo.stbl_System_RolesCapabilities AS RC WITH (NOLOCK)
                        ON RC.RoleID = RM.RoleID
                WHERE
                    RM.Domain = DS.Domain
                    AND RM.[Login] = UT.[Login]
                    AND RC.CapabilityCode IN (
                        N'dcs_approval_can_approve_documents',
                        N'dcs_approval_can_verify_documents'
                    )
            )
    )