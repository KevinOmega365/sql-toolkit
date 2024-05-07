declare @dts_ygg_groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
declare @fdm_ygg_groupRef uniqueidentifier = '5efd7e52-e187-491c-a9cc-1f8f97eebb70'

    select System = 'DTS', RevisionCount = count(*) from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock) where INTEGR_REC_GROUPREF = @dts_ygg_groupRef
union all
    select System = 'FDM', RevisionCount = count(*) from dbo.ltbl_Import_ProArc_RevisionFiles with (nolock) where INTEGR_REC_GROUPREF = @fdm_ygg_groupRef