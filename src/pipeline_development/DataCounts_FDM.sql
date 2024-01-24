
declare @GroupRef uniqueidentifier = '4752565e-84f0-4592-a446-f0720bbc3540'

select
    RAW_Documents = (select count(*) from dbo.ltbl_Import_ProArc_Documents with (nolock) where INTEGR_REC_GROUPREF = @GroupRef),
    RAW_Revisions = (select count(*) from dbo.ltbl_Import_ProArc_Revisions with (nolock) where INTEGR_REC_GROUPREF = @GroupRef),
    RAW_RevisionFiles = (select count(*) from dbo.ltbl_Import_ProArc_RevisionFiles with (nolock) where INTEGR_REC_GROUPREF = @GroupRef)

/**
 * Pipeline Reference
 */
SELECT
    PrimKey,
    Name,
    Description
FROM
    dbo.aviw_Integrations_ScheduledTasksConfigGroups AS [STCG] 