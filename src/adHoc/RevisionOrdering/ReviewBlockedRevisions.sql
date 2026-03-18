/*
 * Details
 */
select
    IR.DCS_Domain,
    IR.DCS_DocumentID,
    IR.DCS_Revision,
    DcsCurrentRevision = D.CurrentRevision,
    DtsCurrentRevision = ID.currentRevision,
    IR.DCS_RevisionDate,
    RevisionsByRevisionDatesDesc =
        '[' + (
            select
                string_agg('["' + Revision + '", "' + convert(nchar(10), Created, 23) + '"]', ', ')
                    within group (order by Created desc)
            from (
                select
                    Revision,
                    Created
                from
                    dbo.atbl_DCS_Revisions R with (nolock)
                where
                    R.Domain = IR.DCS_Domain
                    and R.DocumentID = IR.DCS_DocumentID
            ) as T
        ) + ']',
    IR.INTEGR_REC_ERROR
from
    dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
    join dbo.ltbl_Import_DTS_DCS_Documents ID with (nolock)
        on ID.DCS_Domain = IR.DCS_Domain
        and ID.DCS_DocumentID = IR.DCS_DocumentID
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = ID.DCS_Domain
        and D.DocumentID = ID.DCS_DocumentID
where
    IR.INTEGR_REC_ERROR like 'Quality Failure: Cannot add non-current revision%'
order by
    IR.DCS_Domain,
    IR.DCS_DocumentID,
    IR.DCS_Revision
/*
 * Details
 */
-- select
--     IR.INTEGR_REC_GROUPREF,
--     IR.INTEGR_REC_BATCHREF,
--     IR.INTEGR_REC_STATUS,
--     IR.INTEGR_REC_ERROR,
--     IR.INTEGR_REC_TRACE,
--     IR.JsonRow,
--     IR.object_type,
--     IR.object_importedSourceId,
--     IR.object_guid,
--     IR.contractorReturnCode,
--     IR.documentGuid,
--     IR.documentNumber,
--     IR.proposedWorkflow,
--     IR.reasonForIssue,
--     IR.reasonForIssueDescription,
--     IR.revision,
--     IR.revisionDate,
--     IR.revisionStatus,
--     IR.DCS_Comments,
--     IR.DCS_ContractorSupplierAcceptanceCode,
--     IR.DCS_DocumentID,
--     IR.DCS_Domain,
--     IR.DCS_Import_ExternalUniqueRef,
--     IR.DCS_Revision,
--     IR.DCS_RevisionDate,
--     IR.DCS_Step,
--     IR.DCS_ReasonForIssue,
--     IR.DCS_IsDraft
-- from
--     dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
-- where
--     IR.INTEGR_REC_ERROR like 'Quality Failure: Cannot add non-current revision%'

/*
 * Count
 */
-- select
--     count(*)
-- from
--     dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
-- where
--     INTEGR_REC_ERROR like 'Quality Failure: Cannot add non-current revision%'