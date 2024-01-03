/**
 * Get staging column names
 */
declare @tableName nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents'
declare @columnPattern nvarchar(max) = 'dcs[_]%'

select name
from sys.columns
where
    object_name(object_id) = @tableName
    and name like @columnPattern
order by
    name