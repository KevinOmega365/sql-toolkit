DECLARE
    @Param0 BIT = 0,
    @Param1 NVARCHAR(MAX) = N'%dts%',
    @Param2 NVARCHAR(MAX) = N'%docu%'

SELECT
    [Pipeline].[Name],
    [TimeOfDay] = CONVERT(NVARCHAR(5), [Schedule].[TimeOfDay], 108)
FROM
    [dbo].[aviw_Integrations_ScheduledTasksConfigGroups] [Pipeline]
    JOIN [dbo].[atbv_Integrations_ScheduledTasksConfigGroupsSchedules] [Schedule]
        ON [Schedule].[GroupRef] = [Pipeline].[PrimKey]
WHERE
    (
        [Pipeline].[Inactive] = @Param0
        AND [Pipeline].[SearchColumn] LIKE @Param1
        AND [Pipeline].[SearchColumn] LIKE @Param2
    )
ORDER BY
    [TimeOfDay]