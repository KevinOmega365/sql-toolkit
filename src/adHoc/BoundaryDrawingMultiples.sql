SELECT
    FileAction = CASE
        WHEN Priority > 1
        THEN 'Delete Me'
        ELSE ''
    END
    , *
FROM
(
    select
    DeletionCandidates.Domain,
    DeletionCandidates.DocumentID,
    DeletionCandidates.Revision,
    Priority =
        ROW_NUMBER() OVER (
            PARTITION BY
                DeletionCandidates.Domain,
                DeletionCandidates.DocumentID,
                DeletionCandidates.Revision
            ORDER BY
                DeletionCandidates.Created DESC
        ),
    DeletionCandidates.CreatedBy,
    DeletionCandidates.FileRef,
    DeletionCandidates.Primkey
from
    dbo.atbl_CMS_AkerBP_Compl_DocumentsBoundaryMarkups AS DeletionCandidates WITH (NOLOCK)
where
    exists (
        select
            count(*)
        FROM
            dbo.atbl_CMS_AkerBP_Compl_DocumentsBoundaryMarkups AS FileMultiples WITH (NOLOCK)
        where
            FileMultiples.Domain = DeletionCandidates.Domain
            and FileMultiples.DocumentID = DeletionCandidates.DocumentID
            and FileMultiples.Revision = DeletionCandidates.Revision
        group BY
            FileMultiples.Domain,
            FileMultiples.DocumentID,
            FileMultiples.Revision
        having count(*) > 1
    )
    and
    (
        DeletionCandidates.CreatedBy = 'af_Integrations_ServiceUser'
        or exists (
        select
            *
        FROM
            dbo.atbl_CMS_AkerBP_Compl_DocumentsBoundaryMarkups AS ImportedFiles WITH (NOLOCK)
        where
            ImportedFiles.Domain = DeletionCandidates.Domain
            and ImportedFiles.DocumentID = DeletionCandidates.DocumentID
            and ImportedFiles.Revision = DeletionCandidates.Revision
            and ImportedFiles.Primkey <> DeletionCandidates.Primkey -- a different file
            and ImportedFiles.CreatedBy = 'af_Integrations_ServiceUser'
        )
    )
) T
order by
    Domain,
    DocumentID,
    Revision,
    Priority
