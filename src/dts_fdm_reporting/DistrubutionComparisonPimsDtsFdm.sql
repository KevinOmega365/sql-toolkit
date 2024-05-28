declare
    @groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @action_update nvarchar(128) = '%', -- 'ACTION_UPDATE',
    @dateFormat int = 105

/**
 * Per colum change counts
 */
select
    ColumnName,
    DCS,
    DTS,
    FDM,
    Matching =
        case
            when DCS = DTS and DTS = FDM then 'All'
            when DCS = DTS and DTS <> FDM then 'DCS-DTS'
            when DCS <> DTS and DTS = FDM then 'DTS-FDM'
            when DCS = FDM and DTS != FDM then 'DCS-FDM'
            when DCS <> DTS and DTS <> FDM and DCS != FDM then 'None'
            else ''
        end,
    Count
from
(
    select
        ColumnName,
        DCS,
        DTS,
        FDM,
        Count = count(*)
    from
        (
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'AssetCustomText1'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'AssetCustomText1')),'AssetCustomText1') + ' (AssetCustomText1)', DCS = isnull(D.AssetCustomText1, 'NULL'), DTS = isnull(I.DCS_AssetCustomText1, 'NULL'), FDM = isnull(P.DCS_AssetCustomText1, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'DocsCustomFreeText1'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'DocsCustomFreeText1')),'DocsCustomFreeText1') + ' (DocsCustomFreeText1)', DCS = isnull(D.DocsCustomFreeText1, 'NULL'), DTS = isnull(I.DCS_DocsCustomFreeText1, 'NULL'), FDM = isnull(P.DCS_DocsCustomFreeText1, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'DocsCustomText1'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'DocsCustomText1')),'DocsCustomText1') + ' (DocsCustomText1)', DCS = isnull(D.DocsCustomText1, 'NULL'), DTS = isnull(I.DCS_DocsCustomText1, 'NULL'), FDM = isnull(P.DCS_DocsCustomText1, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'DocsCustomText2'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'DocsCustomText2')),'DocsCustomText2') + ' (DocsCustomText2)', DCS = isnull(D.DocsCustomText2, 'NULL'), DTS = isnull(I.DCS_DocsCustomText2, 'NULL'), FDM = isnull(P.DCS_DocsCustomText2, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'DocsCustomText3'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'DocsCustomText3')),'DocsCustomText3') + ' (DocsCustomText3)', DCS = isnull(D.DocsCustomText3, 'NULL'), DTS = isnull(I.DCS_DocsCustomText3, 'NULL'), FDM = isnull(P.DCS_DocsCustomText3, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'DocsCustomText4'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'DocsCustomText4')),'DocsCustomText4') + ' (DocsCustomText4)', DCS = isnull(D.DocsCustomText4, 'NULL'), DTS = isnull(I.DCS_DocsCustomText4, 'NULL'), FDM = isnull(P.DCS_DocsCustomText4, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'Flag'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'Flag')),'Flag') + ' (Flag)', DCS = isnull(D.Flag, 'NULL'), DTS = isnull(I.DCS_Flag, 'NULL'), FDM = isnull(P.DCS_Flag, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'InstanceCustomText2'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'InstanceCustomText2')),'InstanceCustomText2') + ' (InstanceCustomText2)', DCS = isnull(D.InstanceCustomText2, 'NULL'), DTS = isnull(I.DCS_InstanceCustomText2, 'NULL'), FDM = isnull(P.DCS_InstanceCustomText2, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef union all
            select ColumnName = ISNULL(COALESCE((SELECT Caption FROM dbo.atbl_DCS_CustomFields with (nolock) WHERE [Domain] = D.domain AND CustomField = 'InstanceCustomText3'),(SELECT Caption FROM dbo.atbl_DCS_InstanceCustomFields with (nolock) WHERE InstanceCustomField = 'InstanceCustomText3')),'InstanceCustomText3') + ' (InstanceCustomText3)', DCS = isnull(D.InstanceCustomText3, 'NULL'), DTS = isnull(I.DCS_InstanceCustomText3, 'NULL'), FDM = isnull(P.DCS_InstanceCustomText3, 'NULL') from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock) join dbo.atbl_DCS_Documents D with (nolock) on D.Domain = I.DCS_Domain and D.DocumentID = I.DCS_DocumentID left join dbo.ltbl_Import_ProArc_Documents P with (nolock) on P.DCS_Domain = I.DCS_Domain and P.document_number = I.DCS_DocumentID where I.INTEGR_REC_STATUS like @action_update and I.INTEGR_REC_GROUPREF = @groupRef
        ) T
    group by
        ColumnName,
        DCS,
        DTS,
        FDM
) T
order by
    ColumnName,
    Count desc