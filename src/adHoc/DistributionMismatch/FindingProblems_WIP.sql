
DECLARE @Domain NVARCHAR(128) = '128'
DECLARE @NumberOfDaysBack INT = 35

SELECT
    D.Domain,
    D.DocumentID,
    R.Revision,
    DL.Created,
    DL.FieldName,
    DL.OldValue,
    DL.FieldValue,
    DL.CreatedBy
FROM
    dbo.atbl_DCS_Documents D WITH (NOLOCK)
    JOIN dbo.atbl_DCS_DocumentsLog DL WITH (NOLOCK)
        ON DL.Domain = D.Domain
        AND DL.DocumentID = D.DocumentID
    JOIN dbo.atbl_DCS_Revisions R WITH (NOLOCK)
        ON R.Domain = D.Domain
        AND R.DocumentID = D.DocumentID
        AND R.Revision = D.CurrentRevision
WHERE
    D.Domain = @Domain
    AND DL.Created > CAST(DATEADD(DAY, - @NumberOfDaysBack, GETDATE()) AS DATE)
    AND DL.Created > R.Created
    AND DL.FieldName in (
        'AssetCustomText1',
        'DocsCustomText1',
        'DocsCustomText2',
        'DocsCustomText3',
        'DocsCustomText4',
        'Flag',
        'InstanceCustomText2',
        'InstanceCustomText3'
    )
ORDER BY
    D.DocumentID,
    DL.Created



select top 10 convert(nchar(7), Created, 121) from dbo.stbl_Database_Objects with (nolock) order by newid()




declare @Domain nvarchar(128) = '128'

select
    RevisionDate = convert(nchar(7), R.Created, 121),
    R.Step,
    D.Criticality,
    D.DocExternalVerificationWorkflowStatus,
    D.DocRevisionWorkflowStatus,
    D.DocWorkflowStatus,
    Count = count(*)
from
    dbo.atbl_DCS_Documents D with (nolock)
    join dbo.atbl_DCS_Revisions R with (nolock)
        on R.Domain = D.Domain
        and R.DocumentID = D.DocumentID
        and R.Revision = D.CurrentRevision
    inner join dbo.atbl_DCS_Steps S with (nolock)
        on S.Domain = R.Domain
        and S.Step = R.Step
where
    D.Domain = @Domain
    and S.RequireReview = 1
group by
    convert(nchar(7), R.Created, 121),
    R.Step,
    D.Criticality,
    D.DocExternalVerificationWorkflowStatus,
    D.DocRevisionWorkflowStatus,
    D.DocWorkflowStatus
order by
    convert(nchar(7), R.Created, 121) desc,
    R.Step,
    D.Criticality,
    D.DocExternalVerificationWorkflowStatus,
    D.DocRevisionWorkflowStatus,
    D.DocWorkflowStatus
