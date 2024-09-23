
declare
    @GroupRef nvarchar(36) = N'fb36536c-db59-4926-952a-5868262a44a5',
    @Inactive bit = 0,
    @SearchColumn nvarchar(max) = N'%dts%docu%'

SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [GroupRef],
    [DBObjectID],
    [ExcludeFromBatchHistory]
FROM
    [dbo].[atbv_Integrations_ScheduledTasksConfigGroups_Tables]
WHERE
    [GroupRef] = @GroupRef
ORDER BY
    [DBObjectID]

SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [GroupRef],
    [SequenceOrder],
    [Name],
    [StepType],
    [StepConfig],
    [ContinueOnFailure],
    [SearchColumn],
    [SortOrder],
    [Inactive],
    [InactiveBy],
    [InactiveTime],
    [InactiveReason],
    [DefaultConfigTemplate],
    [InfoElement1],
    [InfoElement2],
    [InfoElement3],
    [TotalNumberOfSubscribers]
FROM
    [dbo].[aviw_Integrations_ScheduledTasksConfigGroupTasks]
WHERE
    [GroupRef] = @GroupRef
ORDER BY
    [SortOrder]


SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [Name],
    [PipelineLevel],
    [LastExecutionTime],
    [LastExecutionErrorMsg],
    [LastExecutionStatusColor],
    [CanBeTriggeredFromPimsRestAPI],
    [Description],
    [SearchColumn],
    [BatchHistory],
    [Inactive],
    [InactiveBy],
    [InactiveTime],
    [InactiveReason],
    [ServiceRef],
    [DashboardRef],
    [TotalNumTasks],
    [TotalNumActiveTasks],
    [TotalNumSchedules],
    [TableSetRef],
    [TableSetID]
FROM
    [dbo].[aviw_Integrations_ScheduledTasksConfigGroups]
WHERE
    (
        [Inactive] = @Inactive
        AND [SearchColumn] LIKE @SearchColumn
    )
ORDER BY
    [Name]
