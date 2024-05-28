select
    *
from
(
    select
        DTS.DCS_Domain,
        DTS.DCS_DocumentID,
        PimsLink = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";C2;"&DocID=";D2);"Open in Pims")',
        FDM.akerbp_distr,
        DTS.companyDistribution,
        DTS.otherCompanyDistributions_CONCATENATED,
        FDM.distributionflags,
        FDM.distributionflags_items,
        DTS.otherCompanyDistributions--,
        -- AssetCustomText1PimsUiName = 'Aker BP Review (AssetCustomText1)',
        -- DTS_DCS_AssetCustomText1 = DTS.DCS_AssetCustomText1,
        -- FDM_DCS_AssetCustomText1 = FDM.DCS_AssetCustomText1,
        -- DocsCustomFreeText1PimsUiName = 'CED (DocsCustomFreeText1)',
        -- DTS_DCS_DocsCustomFreeText1 = DTS.DCS_DocsCustomFreeText1,
        -- FDM_DCS_DocsCustomFreeText1 = FDM.DCS_DocsCustomFreeText1,
        -- FlagPimsUiName = 'Flag (Flag)',
        -- DTS_DCS_Flag = DTS.DCS_Flag,
        -- FDM_DCS_Flag = FDM.DCS_Flag,
        -- InstanceCustomText2PimsUiName = 'ModificationAlliance (InstanceCustomText2)',
        -- DTS_DCS_InstanceCustomText2 = DTS.DCS_InstanceCustomText2,
        -- FDM_DCS_InstanceCustomText2 = FDM.DCS_InstanceCustomText2,
        -- DocsCustomText4PimsUiName = 'Munin (Aibel) (DocsCustomText4)',
        -- DTS_DCS_DocsCustomText4 = DTS.DCS_DocsCustomText4,
        -- FDM_DCS_DocsCustomText4 = FDM.DCS_DocsCustomText4,
        -- DocsCustomText3PimsUiName = 'PFS (Incl. Akso, MUC and Equinor) (DocsCustomText3)',
        -- DTS_DCS_DocsCustomText3 = DTS.DCS_DocsCustomText3,
        -- FDM_DCS_DocsCustomText3 = FDM.DCS_DocsCustomText3,
        -- InstanceCustomText3PimsUiName = 'SubseaAlliance (InstanceCustomText3)',
        -- DTS_DCS_InstanceCustomText3 = DTS.DCS_InstanceCustomText3,
        -- FDM_DCS_InstanceCustomText3 = FDM.DCS_InstanceCustomText3,
        -- DocsCustomText2PimsUiName = 'TI Hugin A og B Heerema (DocsCustomText2)',
        -- DTS_DCS_DocsCustomText2 = DTS.DCS_DocsCustomText2,
        -- FDM_DCS_DocsCustomText2 = FDM.DCS_DocsCustomText2,
        -- DocsCustomText1PimsUiName = 'TI Hugin A Topside Allseas (DocsCustomText1)',
        -- DTS_DCS_DocsCustomText1 = DTS.DCS_DocsCustomText1,
        -- FDM_DCS_DocsCustomText1 = FDM.DCS_DocsCustomText1
    from
        dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
        join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
            on FDM.DCS_Domain = DTS.DCS_Domain
            and FDM.document_number = DTS.DCS_DocumentID
    where
        isnull(DTS.DCS_AssetCustomText1, '') <> isnull(FDM.DCS_AssetCustomText1, '')
        or isnull(DTS.DCS_DocsCustomFreeText1, '') <> isnull(FDM.DCS_DocsCustomFreeText1, '')
        or isnull(DTS.DCS_Flag, '') <> isnull(FDM.DCS_Flag, '')
        or isnull(DTS.DCS_InstanceCustomText2, '') <> isnull(FDM.DCS_InstanceCustomText2, '')
        or isnull(DTS.DCS_DocsCustomText4, '') <> isnull(FDM.DCS_DocsCustomText4, '')
        or isnull(DTS.DCS_DocsCustomText3, '') <> isnull(FDM.DCS_DocsCustomText3, '')
        or isnull(DTS.DCS_InstanceCustomText3, '') <> isnull(FDM.DCS_InstanceCustomText3, '')
        or isnull(DTS.DCS_DocsCustomText2, '') <> isnull(FDM.DCS_DocsCustomText2, '')
        or isnull(DTS.DCS_DocsCustomText1, '') <> isnull(FDM.DCS_DocsCustomText1, '')
) T