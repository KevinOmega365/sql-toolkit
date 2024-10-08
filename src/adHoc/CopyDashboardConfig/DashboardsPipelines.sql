DECLARE
    @Param0 nvarchar(1000) = N'%dts%',
    @Param1 nvarchar(1000) = N'%docu%',
    @Param2 bit = 0

SELECT
    DI.PrimKey,
    DI.Created,
    DI.CreatedBy,
    DI.Updated,
    DI.UpdatedBy,
    DI.CUT,
    DI.CDL,
    DI.ServiceRef,
    DI.Config,
    DI.Inactive,
    DI.Comment,
    DI.TableSetRef
FROM
    [dbo].[atbl_Integrations_DashboardItems] DI WITH (NOLOCK)
    JOIN dbo.atbl_Integrations_Services AS S WITH (NOLOCK)
        ON S.PrimKey = DI.ServiceRef
    JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG WITH (NOLOCK)
        ON STCG.PrimKey = S.EndpointRef
WHERE
    (
        [EndpointName] LIKE @Param0
        AND [EndpointName] LIKE @Param1
        AND STCG.[Inactive] = @Param2
    )
ORDER BY
    [ServiceTypeID],
    [EndpointName]