declare
    @groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @action_update nvarchar(128) = 'ACTION_UPDATE',
    @dateFormat int = 105

/**
 * Per colum change counts
 */
select
    ColumnName,
    Change,
    Count = count(*)
from
    (
        select ColumnName = 'AssetCustomText1', Change = cast(case when isnull(D.AssetCustomText1, '') <> isnull(I.DCS_AssetCustomText1, '') then isnull(D.AssetCustomText1, 'NULL') + ' -> ' + isnull(I.DCS_AssetCustomText1, 'NULL') else '' end as nvarchar(max)) from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'DocsCustomFreeText1', Change = case when isnull(D.DocsCustomFreeText1, '') <> isnull(I.DCS_DocsCustomFreeText1, '') then isnull(D.DocsCustomFreeText1, 'NULL') + ' -> ' + isnull(I.DCS_DocsCustomFreeText1, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'DocsCustomText1', Change = case when isnull(D.DocsCustomText1, '') <> isnull(I.DCS_DocsCustomText1, '') then isnull(D.DocsCustomText1, 'NULL') + ' -> ' + isnull(I.DCS_DocsCustomText1, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'DocsCustomText2', Change = case when isnull(D.DocsCustomText2, '') <> isnull(I.DCS_DocsCustomText2, '') then isnull(D.DocsCustomText2, 'NULL') + ' -> ' + isnull(I.DCS_DocsCustomText2, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'DocsCustomText3', Change = case when isnull(D.DocsCustomText3, '') <> isnull(I.DCS_DocsCustomText3, '') then isnull(D.DocsCustomText3, 'NULL') + ' -> ' + isnull(I.DCS_DocsCustomText3, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'DocsCustomText4', Change = case when isnull(D.DocsCustomText4, '') <> isnull(I.DCS_DocsCustomText4, '') then isnull(D.DocsCustomText4, 'NULL') + ' -> ' + isnull(I.DCS_DocsCustomText4, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'Flag', Change = case when isnull(D.Flag, '') <> isnull(I.DCS_Flag, '') then isnull(D.Flag, 'NULL') + ' -> ' + isnull(I.DCS_Flag, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'InstanceCustomText2', Change = case when isnull(D.InstanceCustomText2, '') <> isnull(I.DCS_InstanceCustomText2, '') then isnull(D.InstanceCustomText2, 'NULL') + ' -> ' + isnull(I.DCS_InstanceCustomText2, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef union all
        select ColumnName = 'InstanceCustomText3', Change = case when isnull(D.InstanceCustomText3, '') <> isnull(I.DCS_InstanceCustomText3, '') then isnull(D.InstanceCustomText3, 'NULL') + ' -> ' + isnull(I.DCS_InstanceCustomText3, 'NULL') else '' end from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID where INTEGR_REC_STATUS = @action_update and INTEGR_REC_GROUPREF = @groupRef
    ) T
where
    Change <> ''
group by
    ColumnName,
Change
order by
    ColumnName,
    Count desc