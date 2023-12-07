-------------------------------------------------------------------------------
--------------------------------------------------------- Chain-step mapping --
-------------------------------------------------------------------------------

/**
 * All of the Logic Fields Permutation Counts
 */
DECLARE @BatchRef UNIQUEIDENTIFIER = '10d56ecb-f34f-4329-9362-94886e7b6bb4'

SELECT
    InstanceCount = COUNT(*),
    DCS_Step,
    DCS_Domain,
    DCS_Revision,
    CurrentRevision,
    PrevPimsRevision,
    chain,
    DCS_ReviewClass,
    ReviewClassName,
    ReviewStatus,
    PrevRevReviewStatusName,
    Step,
    reasonForIssue,
    DCS_Criticality
FROM
    (
        SELECT
            ProarcRev.DCS_Step,
            ProarcRev.DCS_DocumentID,
            ProarcRev.DCS_Domain,
            ProarcRev.DCS_Revision,
            PimsDoc.CurrentRevision,
            PrevPimsRevision = PrevPimsRev.Revision,
            ProarcDoc.chain,
            ProarcDoc.DCS_ReviewClass,
            ReviewClassName = (
                SELECT SystemReviewClass
                FROM dbo.atbl_DCS_ReviewClasses RC WITH (NOLOCK)
                WHERE
                    RC.Domain = ProarcDoc.DCS_Domain
                    and RC.ReviewClass = ProarcDoc.DCS_ReviewClass
            ),
            PrevPimsRev.ReviewStatus,
            PrevRevReviewStatusName = (
                SELECT SystemReviewStatus -- Description
                FROM dbo.atbl_DCS_ReviewStatuses RS WITH (NOLOCK)
                WHERE
                    RS.Domain = PrevPimsRev.Domain
                    AND RS.ReviewStatus = PrevPimsRev.ReviewStatus
            ),
            PrevPimsRev.Step,
            ProarcRev.reasonForIssue,
            ProarcDoc.DCS_Criticality
        FROM
            dbo.ltbl_Import_MuninAibel_Revisions AS ProarcRev WITH (NOLOCK)
            LEFT JOIN dbo.ltbl_Import_MuninAibel_Documents AS ProarcDoc WITH (NOLOCK)
                ON ProarcRev.DCS_Domain = ProarcDoc.DCS_Domain
                AND ProarcRev.DCS_DocumentID = ProarcDoc.DCS_DocumentID
                AND ProarcRev.INTEGR_REC_BATCHREF = ProarcDoc.INTEGR_REC_BATCHREF
            LEFT JOIN dbo.atbl_DCS_Revisions AS PimsRev WITH (NOLOCK)
                ON ProarcRev.DCS_Domain = PimsRev.Domain
                AND ProarcRev.DCS_DocumentID = PimsRev.DocumentID
                AND ProarcRev.DCS_Revision = PimsRev.Revision
            LEFT JOIN dbo.atbl_DCS_Documents AS PimsDoc WITH (NOLOCK)
                ON PimsDoc.Domain = PimsRev.Domain
                AND PimsDoc.DocumentID = PimsRev.DocumentID
            LEFT JOIN dbo.atbl_DCS_Revisions AS PrevPimsRev WITH (NOLOCK)
                ON PrevPimsRev.Domain = PimsDoc.Domain
                AND PrevPimsRev.DocumentID = PimsDoc.DocumentID
                AND PrevPimsRev.RevisionItemNo = PimsDoc.PrevRevItemNo
        WHERE
            ProarcRev.INTEGR_REC_BATCHREF = @BatchRef
    ) T
GROUP BY
    DCS_Step,
    DCS_Domain,
    DCS_Revision,
    CurrentRevision,
    PrevPimsRevision,
    chain,
    DCS_ReviewClass,
    ReviewClassName,
    ReviewStatus,
    PrevRevReviewStatusName,
    Step,
    reasonForIssue,
    DCS_Criticality
ORDER BY
    InstanceCount DESC