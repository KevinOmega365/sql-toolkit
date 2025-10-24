
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Valhall -- '%'

declare @DomainList table (
    DCS_Domain nvarchar(128)
)
insert into @DomainList
select DCS_Domain
from dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
where INTEGR_REC_GROUPREF like @GroupRef

/*
 * Document List
 * Inlcudes links for
 *   af-dbmanager (bookmarklet) and
 *   Excel (activate and copy down {ctrl+shift+end; ctrl+d})
 */
SELECT
    -- -- live links in af-db-manager
    -- activate_link_document =
    --     '<a href="' +
    --     'https://pims.akerbp.com/dcs-documents-details?Domain=' +
    --     R.Domain +
    --     '&DocID=' +
    --     R.DocumentID +
    --     '">' +
    --     R.DocumentID +
    --     '</a>',
    R.Domain,
    R.DocumentID,
    R.Revision,
    RevisionFileCount = ( -- can be zero
        SELECT COUNT(*)
        FROM
            dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
        WHERE
            RF.Domain = R.Domain
            AND RF.DocumentID = R.DocumentID
            AND RF.RevisionItemNo = R.RevisionItemNo
    ),
    D.IsVoided,
    D.IsSuperseded
    -- , URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)'
FROM
    dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
    JOIN dbo.atbl_DCS_Documents D WITH (NOLOCK)
        ON D.Domain = R.Domain
        AND D.DocumentID = R.DocumentID
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Revisions AS IR WITH  (NOLOCK)
        ON IR.DCS_Domain = R.Domain
        AND IR.DCS_DocumentID = R.DocumentID
        AND IR.DCS_Revision = R.Revision
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Documents AS ID WITH  (NOLOCK)
        ON ID.DCS_Domain = IR.DCS_Domain
        AND ID.DCS_DocumentID = IR.DCS_DocumentID
WHERE
    IR.PrimKey IS NULL
    AND R.Domain IN (select DCS_Domain from @DomainList)
    AND R.CreatedBy = 'af_Integrations_ServiceUser'
ORDER BY
    R.Domain,
    R.DocumentID,
    R.Revision

/*
 * Domain count
 */
SELECT
    R.Domain,
    OrphanedRevisions = COUNT(*)
FROM
    dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Revisions AS I WITH  (NOLOCK)
        ON I.DCS_Domain = R.Domain
        AND I.DCS_DocumentID = R.DocumentID
        AND I.DCS_Revision = R.Revision
WHERE
    I.PrimKey IS NULL
    AND R.Domain IN (select DCS_Domain from @DomainList)
    AND R.CreatedBy = 'af_Integrations_ServiceUser'
GROUP BY
    R.Domain
