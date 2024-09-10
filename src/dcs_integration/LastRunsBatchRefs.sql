
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
            Groups.Primkey = INTEGR_REC_GROUPREF
    ),
    INTEGR_REC_GROUPREF,
    INTEGR_REC_BATCHREF
FROM
    dbo.ltbl_Import_DTS_DCS_Documents WITH (NOLOCK)
