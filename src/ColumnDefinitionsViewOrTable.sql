DECLARE @viewOrTableName NVARCHAR(128) = 'aviw_RiskMgmt_Web_Risks'

SELECT
    c.name,
    type_name(c.system_type_id) columnType
FROM
    sys.objects o
    JOIN sys.columns c
        on c.object_id = o.object_id
WHERE
    o.name = @viewOrTableName