/*
 * Activity Run Time with Errors
 */ 
SELECT
    [ScheduleRef],
    [ExecutionBatchRef],
    [GroupRef],
    [TaskRef],
    [Name],
    [TaskName],
    [Status],
    [Initiated],
    [ExecutionStart],
    [ExecutionEnd],
    [Duration],
    [SortOrder],
    [ErrorMsg]
FROM
    [dbo].[aviw_Integrations_ScheduledTasksActivityMonitor]
ORDER BY
    [Initiated] DESC,
    [GroupRef],
    [SortOrder]
OFFSET
    0 ROWS
FETCH FIRST
    50 ROWS ONLY

/*
 * Status Count Archive
 */
SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [ConfigurationGroupRef],
    [ExecutionBatchRef],
    [TableName],
    [ImportStatus],
    [Count],
    [PipelineName]
FROM
    [dbo].[aviw_Integrations_ImportStatusCountArchive]
ORDER BY
    [Created] DESC
OFFSET
    0 ROWS
FETCH
    FIRST 50 ROWS ONLY

/*
 * DTS - DCS Pipelines
 */
select
    Name
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
where
    PrimKey in
    (
        'edadd424-81ce-4170-b419-12642f80cfde',
        'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
        '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
        'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
        'f6c3687c-5511-48f2-98e5-8e84eee9b689'
    )