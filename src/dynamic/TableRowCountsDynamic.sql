declare @tableNamePattern nvarchar(128) = 'ltbl_Import_DTS_DCS%'
declare @unionAll nchar(11) = ' union all '
declare @orderBy nvarchar(max) = ' order by TableName' -- ' order by RecordCount desc' --
declare @sqlQuery nvarchar(max)

select @sqlQuery = string_agg(SqlStatement, @unionAll) + @orderBy
from
(
    select
        SqlStatement = 'select RecordCount = (select count(*) from dbo.' + name + ' with (nolock)), TableName = ''' + name + ''''
    from
        sys.objects
    where
        name like @tableNamePattern
        and type = 'u'
) TablesCounts

-- print @sqlQuery -- debug

exec sp_executesql @sqlQuery
