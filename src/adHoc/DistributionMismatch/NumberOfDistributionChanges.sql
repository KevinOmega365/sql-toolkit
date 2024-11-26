-- TODO: Document and string_agg of changes and calculated step.
-- TODO: Include Safety.

select
    Domain,
    NumberOfDocuments = count(*),
    MinDistributionChanges = min(NumberOfDistributionChanges),
    AvgDistributionChanges = avg(NumberOfDistributionChanges),
    MaxDistributionChanges = max(NumberOfDistributionChanges)
from
(
    select
        D.Domain,
        D.DocumentID,
        count(*) NumberOfDistributionChanges
    from
        dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
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
        and L.Created > R.Created
    group by
        D.Domain,
        D.DocumentID
) T
group by
    Domain

/*
 * total changes
 */
-- select count(*) NumberOfDistributionChanges
-- from
--     dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
--     join dbo.atbl_DCS_Documents D with (nolock)
--         on D.Domain = I.DCS_Domain
--         and D.DocumentID = I.DCS_DocumentID
--     join dbo.atbl_DCS_Revisions R with (nolock)
--         on R.Domain = D.Domain
--         and R.DocumentID = D.DocumentID
--         and R.Revision = D.CurrentRevision
--     join dbo.atbl_DCS_DocumentsLog L with (nolock)
--         on L.Domain = D.Domain
--         and L.DocumentID = D.DocumentID
-- where
--     -- I.DCS_Domain = '128'
--     -- and
--     L.FieldName in (
--         'AssetCustomText1',
--         'DocsCustomFreeText1',
--         'DocsCustomText1',
--         'DocsCustomText2',
--         'DocsCustomText3',
--         'DocsCustomText4',
--         'Flag',
--         'InstanceCustomText2',
--         'InstanceCustomText3'
--     )
--     and L.Created > R.Created
