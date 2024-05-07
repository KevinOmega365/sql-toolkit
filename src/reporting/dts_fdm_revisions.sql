declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'


/**
 * Revsion counts from common documents
 */
    select
        System = 'DTS',
        RevisionCount = count(*)
    from
        (
            select
                documentNumber
            from
                dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
                join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
                    on FDM.document_number = DTS.documentnumber
            where
                DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
                AND FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef

        ) CommonDocuments
        left join dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
            on DTS.documentnumber = CommonDocuments.documentnumber
union all
    select
        System = 'FDM',
        RevisionCount = count(*)
    from
        (
            select
                documentNumber
            from
                dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
                join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
                    on FDM.document_number = DTS.documentnumber
            where
                DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
                AND FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef

        ) CommonDocuments
        left join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
            on FDM.document_number = CommonDocuments.documentnumber


/**
 * Revsion counts
 */
    select
        System = 'Both',
        RevisionCount = count(*)
    from
        dbo.ltbl_Import_DTS_DCS_Revisions DTS with (nolock)
        join dbo.ltbl_Import_ProArc_Revisions FDM with (nolock)
            on FDM.document_number = DTS.documentnumber
            and FDM.revision = DTS.revision
    where
        DTS.INTEGR_REC_GROUPREF = @dts_ygg_groupRef
        AND FDM.INTEGR_REC_GROUPREF = @fdm_ygg_groupRef
union all
    select System = 'DTS', RevisionCount = count(*) from dbo.ltbl_Import_DTS_DCS_Revisions with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef
union all
    select System = 'FDM', RevisionCount = count(*) from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef