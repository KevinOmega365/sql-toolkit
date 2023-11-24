DECLARE
    @SourceName NVARCHAR(100) = 'document',
    @SourceSystem NVARCHAR(100) = 'cdf-proarc-noafulla',
    @NewEntryName NVARCHAR(100) = 'revision',
    @NewEntrySystem NVARCHAR(100) = 'cdf-proarc-noafulla'

-- INSERT INTO [dbo].[atbl_Integrations_Setup_Endpoints]
-- (
--     Comments,
--     Description,
--     EndpointConfig,
--     InterfaceAssemblyMethodRef,
--     Mapping,
--     Name,
--     Query,
--     System
-- )
SELECT
    Comments,
    Description,
    EndpointConfig,
    InterfaceAssemblyMethodRef,
    Mapping,
    Name = @NewEntryName,
    Query,
    System = @NewEntrySystem
FROM
    [dbo].[atbl_Integrations_Setup_Endpoints] WITH (NOLOCK)
WHERE
    [System] LIKE @SourceSystem
    AND Name = @SourceName
