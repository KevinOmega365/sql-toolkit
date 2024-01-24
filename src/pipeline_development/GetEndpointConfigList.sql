declare
    @Param0 nvarchar(100) = N'%dts%',
    @Param1 nvarchar(100) = N'%ivar%'

SELECT
    [System],
    [Name],
    [Description],
    [EndpointConfig],
    [Query],
    [Mapping],
    [Comments],
    [InterfaceAssemblyMethodRef]
FROM
    [dbo].[aviw_Integrations_Setup_Endpoints]
WHERE
    (
        [System] LIKE @Param0
        AND [System] LIKE @Param1
    )
