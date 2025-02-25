/*
 * DTS Source ID from Endpoint Configuration Query URI
 */
declare
    @Param0 nvarchar(100) = N'%dts%',
    @Param1 nvarchar(100) = N'%docu%',
    @Param2 nvarchar(max) = N'%new%'
SELECT

    [System],
    -- [Name],
    -- [Description],
    -- QueryUri = (json_value(EndpointConfig, '$.QueryUri')),
    SourceId = left(reverse(left(reverse((json_value(EndpointConfig, '$.QueryUri'))), 37)), 36)
FROM
    [dbo].[aviw_Integrations_Setup_Endpoints]
WHERE
    (
        [System] LIKE @Param0
        AND [Name] LIKE @Param1
        AND [Description] LIKE @Param2
    )
