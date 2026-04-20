declare @tablePattern nvarchar(128) = 'ltbl_Import_DTS_DCS_Files'
declare @columnPattern nvarchar(128) = '%'
declare @prefixLength int = 0

/*
 * JSON
 */
select
    tableName = object_name(object_id),
    columnNames = json_query('[' + string_agg('"' + right(name, len(name) - @prefixLength) + '"', ', ') + ']')
from
    sys.columns
where
    object_name(object_id) like @tablePattern
    and name like @columnPattern
group by
    object_id
order by
    TableName
for
    json auto

/*
 * Aggregated tabular
 */
select
    tableName = object_name(object_id),
    columnNames = '[' + string_agg('"' + right(name, len(name) - @prefixLength) + '"', ', ') within group (order by name) + ']'
from
    sys.columns
where
    object_name(object_id) like @tablePattern
    and name like @columnPattern
group by
    object_id
order by
    TableName

/*
 * Tabular
 */
select
    TableName = object_name(object_id),
    ColumnName = name
from
    sys.columns
where
    object_name(object_id) like @tablePattern
    and name like @columnPattern
order by
    TableName,
    ColumnName
