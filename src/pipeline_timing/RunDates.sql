/*
 * Run dates
 */
SELECT
    RunDate
FROM
    (
        SELECT
            RunDate = CAST(Initiated AS date)
        FROM
            dbo.aviw_Integrations_ScheduledTasksActivityMonitor Runs
        WHERE
            GroupRef IN (
                'edadd424-81ce-4170-b419-12642f80cfde',
                'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
                '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
                'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
                'f6c3687c-5511-48f2-98e5-8e84eee9b689'
            )
    ) T
GROUP BY
    RunDate
ORDER BY
    RunDate DESC