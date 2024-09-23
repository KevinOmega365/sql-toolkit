
declare
    @GroupRef nvarchar(36) = N'fb36536c-db59-4926-952a-5868262a44a5',
    @Inactive bit = 0,
    @SearchColumn nvarchar(max) = N'%dts%docu%'

SELECT
    Count = count(*),
    -- [PrimKey],
    -- [Created],
    -- [CreatedBy],
    -- [Updated],
    -- [UpdatedBy],
    -- [GroupRef],
    [SequenceOrder],
    [Name],
    [StepType],
    [StepConfig],
    [ContinueOnFailure],
    [SearchColumn],
    [SortOrder],
    -- [Inactive],
    [InactiveBy],
    [InactiveTime],
    [InactiveReason],
    [DefaultConfigTemplate],
    [InfoElement1],
    [InfoElement2],
    [InfoElement3]--,
    -- [TotalNumberOfSubscribers]
FROM
    [dbo].[aviw_Integrations_ScheduledTasksConfigGroupTasks]
WHERE
    [GroupRef] IN (

        SELECT [PrimKey]
        FROM [dbo].[aviw_Integrations_ScheduledTasksConfigGroups]
        WHERE
            [Inactive] = @Inactive
            AND [SearchColumn] LIKE @SearchColumn
    )

group by
    [SequenceOrder],
    [Name],
    [StepType],
    [StepConfig],
    [ContinueOnFailure],
    [SearchColumn],
    [SortOrder],
    -- [Inactive], 
    [InactiveBy],
    [InactiveTime],
    [InactiveReason],
    [DefaultConfigTemplate],
    [InfoElement1],
    [InfoElement2],
    [InfoElement3]--,

order by
    cast(SequenceOrder as float)