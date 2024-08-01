declare
    @groupRef uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @action_update nvarchar(128) = 'ACTION_UPDATE',
    @dateFormat int = 105

/**
 * Per-document changes
 */
select * -- top 50 *
from (
    select
        D.Domain
        , DocumentID = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain=' + D.Domain + '&DocID=' + D.DocumentID + '";"' + D.DocumentID + '")'
        , D.Title
        , D.CurrentRevision as PimsCurrentRevision
        , I.currentRevision as ImportCurrentRevision
        , D.IsSuperseded as PimsIsSuperseded
        , I.supersededBy as ImportSupersededBy
        , D.Voided as PimsVoided
        , I.DCS_VoidedDate as ImportDcsVoidedDate
        , I.documentStatus as ImportDocumentStatus
    from
        dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
        join dbo.atbl_DCS_Documents D with (nolock)
            on D.Domain = I.DCS_Domain
            and D.DocumentID = I.DCS_DocumentID
    where
        INTEGR_REC_STATUS = @action_update
        and INTEGR_REC_GROUPREF = @groupRef
        and isnull(D.VoidedDate, '') <> isnull(I.DCS_VoidedDate, '')
) T
order by
    Domain,
    DocumentID