/**
 * Check Document Existence
 */
declare @QuestionDocuments table (
    DocumentID nvarchar(max),
    Revision nvarchar(max)
)
insert into @QuestionDocuments
values
    ('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION') --, ...

select distinct *
from
(
    select -- distinct
        ImportDomain = ID.DCS_Domain,   
        Q.DocumentID,
        Q.Revision,
        ImportDocumentExists = case when ID.PrimKey is null then 0 else 1 end,
        ImportRevisionExists = case when IR.PrimKey is null then 0 else 1 end,
        PimsDocumentExists = case when PD.PrimKey is null then 0 else 1 end,
        PimsRevisionExists = case when PR.PrimKey is null then 0 else 1 end
    from
        @QuestionDocuments Q -- hang everything off Q
        left join dbo.ltbl_Import_DTS_DCS_Documents as ID with (nolock)
            on ID.DCS_DocumentID = Q.DocumentID
        left join dbo.ltbl_Import_DTS_DCS_Revisions as IR with (nolock)
            on IR.DCS_DocumentID = Q.DocumentID
            and IR.DCS_Revision = Q.Revision
        left join dbo.atbl_DCS_Documents as PD with (nolock)
            on PD.DocumentID = Q.DocumentID
        left join dbo.atbl_DCS_Revisions as PR with (nolock)
            on PR.DocumentID = Q.DocumentID
            and PR.Revision = Q.Revision
) T
where
    ImportDocumentExists = 0
    or ImportRevisionExists = 0
    or PimsDocumentExists = 0
    or PimsRevisionExists = 0
order by
    DocumentID,
    Revision