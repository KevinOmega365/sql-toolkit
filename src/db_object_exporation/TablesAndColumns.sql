select
    TableName = T.Name,
    ColumnName = C.Name,
    ColumnType = type_name(system_type_id),
    ColumnLength = c.max_length,
    ColumnPrecision = c.precision,
    ColumnScale = c.scale
from
    sys.objects T
    join sys.columns C
        on C.object_id = T.object_id
where
    T.name like 'atb__TGE_AzureAd%'
    and T.type in ('u', 'v')
order by
    TableName,
    ColumnName
