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

-- or

select
    name,
    system_type_name
from
    sys.dm_exec_describe_first_result_set(
        'select * from ' + @viewOrTableName,
        null,
        0
    )
