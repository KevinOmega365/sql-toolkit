declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef uniqueidentifier = @Yggdrasil

select
    L.Domain, 
	L.DocumentID,
    L.FieldName,
    L.FieldValue,
    L.OldValue,
    L.Created,
    RevisionDate = R.Created,
    L.CreatedBy
from
    dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = I.DCS_Domain
        and D.DocumentID = I.DCS_DocumentID
    join dbo.atbl_DCS_Revisions R with (nolock)
        on R.Domain = D.Domain
        and R.DocumentID = D.DocumentID
        and R.Revision = D.CurrentRevision
    join dbo.atbl_DCS_DocumentsLog L with (nolock)
        on L.Domain = D.Domain
        and L.DocumentID = D.DocumentID
where
    I.INTEGR_REC_GROUPREF = @Yggdrasil
    and
    L.Created > R.Created
    and L.Created > '2024-1-1'
    and
    L.FieldName in (
        'AssetCustomText1',
        'DocsCustomFreeText1',
        'DocsCustomText1',
        'DocsCustomText2',
        'DocsCustomText3',
        'DocsCustomText4',
        'Flag',
        'InstanceCustomText2',
        'InstanceCustomText3'
    )
-- order by
--     DocumentID,
--     L.Created desc
