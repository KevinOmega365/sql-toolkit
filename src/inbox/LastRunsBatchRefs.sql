
/*
 * Integrations Last Runs
 */
SELECT DISTINCT
    Integration = (
        SELECT
            Name
        FROM
            dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Groups WITH (NOLOCK)
        WHERE
            Groups.Primkey = DTS.INTEGR_REC_GROUPREF
    ),
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF
FROM
    dbo.ltbl_Import_MuninAibel_Documents_RAW DTS WITH (NOLOCK)

UNION ALL

SELECT DISTINCT
    Integration = (
        SELECT
            Name
        FROM
            dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Groups WITH (NOLOCK)
        WHERE
            Groups.Primkey = FDM.INTEGR_REC_GROUPREF
    ),
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF
FROM
    dbo.ltbl_Import_ProArc_Documents FDM WITH (NOLOCK)