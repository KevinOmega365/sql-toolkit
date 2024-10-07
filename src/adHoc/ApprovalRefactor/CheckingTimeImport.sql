/*
 * Missing Receiver People
 */
-- select
--     T.Domain
--     ,T.DocumentID
--     ,T.RevisionItemNo
--     ,T.ReceiverPerson
--     ,T.ActionType
-- from
--     (
--         SELECT DISTINCT -- duplicates
--             INTEGR_REC_BATCHREF,
--             INTEGR_REC_GROUPREF,
--             R.Domain,
--             R.DocumentID,
--             R.RevisionItemNo,
--             DS.ReceiverPerson,
--             DS.ActionType,
--             DS.SequentialOrder,
--             ApprovalDeadline = NULL, -- see transform
--             SystemGenerated = 1,
--             Selected = 0

--             , DCS_R_STEP
--         FROM
--             dbo.atbl_Import_Time_Documents_Final AS I WITH (NOLOCK)
--             JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--                 ON R.Domain = I.DCS_Domain
--                 AND R.DocumentID = I.DOCUMENT_NO + ';' + I.PROJECT_NO + ';' + I.UNO
--                 AND R.Revision = I.revision
--             JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
--                 ON DS.Domain = I.DCS_Domain
--                 AND DS.DocumentID = I.DOCUMENT_NO + ';' + I.PROJECT_NO + ';' + I.UNO
--         WHERE
--             DS.DistributionType = N'Approval'
--             AND I.INTEGR_REC_STATUS <> 'OUT_OF_SCOPE'
--             -- AND I.INTEGR_REC_BATCHREF = @BatchRef
--     ) T
-- where
--     DCS_R_STEP = 'IFA'
--     and not exists (
--         SELECT
--             *
--         FROM
--             dbo.atbl_DCS_Approval AS [A] WITH (NOLOCK)
--             LEFT JOIN dbo.atbl_DCS_ApprovalReceivers AS [AR] WITH (NOLOCK)
--                 ON AR.Domain = A.Domain
--                 AND AR.ApprovalID = A.ApprovalID
--             LEFT JOIN dbo.atbl_ProjectSetup_Persons AS [P] WITH (nolock)
--                 ON AR.ReceiverLogin = P.Login
--         WHERE
--             A.Domain = T.Domain
--             AND A.DocumentID = T.DocumentID
--             AND A.RevisionItemNo = T.RevisionItemNo
--             AND P.PersonID = T.ReceiverPerson
--     )

/*
 * Document Revisions to Check
 */
select distinct
    T.Domain
    ,T.DocumentID
    ,T.RevisionItemNo
from
    (
        SELECT DISTINCT -- duplicates
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

            , DCS_R_STEP
        FROM
            dbo.atbl_Import_Time_Documents_Final AS I WITH (NOLOCK)
            JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
                ON R.Domain = I.DCS_Domain
                AND R.DocumentID = I.DOCUMENT_NO + ';' + I.PROJECT_NO + ';' + I.UNO
                AND R.Revision = I.revision
            JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
                ON DS.Domain = I.DCS_Domain
                AND DS.DocumentID = I.DOCUMENT_NO + ';' + I.PROJECT_NO + ';' + I.UNO
        WHERE
            DS.DistributionType = N'Approval'
            AND I.INTEGR_REC_STATUS <> 'OUT_OF_SCOPE'
            -- AND I.INTEGR_REC_BATCHREF = @BatchRef
    ) T
where
    DCS_R_STEP = 'IFA'
    and not exists (
        SELECT
            *
        FROM
            dbo.atbl_DCS_Approval AS [A] WITH (NOLOCK)
            LEFT JOIN dbo.atbl_DCS_ApprovalReceivers AS [AR] WITH (NOLOCK)
                ON AR.Domain = A.Domain
                AND AR.ApprovalID = A.ApprovalID
            LEFT JOIN dbo.atbl_ProjectSetup_Persons AS [P] WITH (nolock)
                ON AR.ReceiverLogin = P.Login
        WHERE
            A.Domain = T.Domain
            AND A.DocumentID = T.DocumentID
            AND A.RevisionItemNo = T.RevisionItemNo
            AND P.PersonID = T.ReceiverPerson
    )

/*
 * Import Tray Items Status Counts
 */
-- SELECT
--     Status = INTEGR_REC_STATUS,
--     Count = count(*)
-- FROM
--     dbo.ltbl_Import_Time_DCS_RevisionsApprovalTrayItems WITH (nolock)
-- group by
--     INTEGR_REC_STATUS
-- order by
--     INTEGR_REC_STATUS

-- SELECT
--     INTEGR_REC_STATUS,
--     INTEGR_REC_ERROR,
--     INTEGR_REC_TRACE,
--     DCS_Domain,
--     DCS_DocumentID,
--     DCS_RevisionItemNo,
--     DCS_Receiver,
--     DCS_ActionType,
--     DCS_SequentialOrder,
--     DCS_ApprovalDeadline,
--     DCS_SystemGenerated,
--     DCS_Selected
-- FROM
--     dbo.ltbl_Import_Time_DCS_RevisionsApprovalTrayItems WITH (nolock)
