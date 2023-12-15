
declare @TableName nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents'

declare @Statement nvarchar(max) = ''

set @Statement += 'select TotalRowCount = (select count(*) from dbo.' + @TableName + ' with (nolock)),'

declare @ColumnSubSelections nvarchar(max) = (
    select string_agg(cast(columnNullCount as nvarchar(max)), ',')
    from
        (
            select columnNullCount = 'missing_' + name + ' = (select count(*) from dbo.' + @TableName + ' with (nolock) where ' + name + ' is null)'
            from sys.columns where object_id = object_id(@TableName)
        ) T
)

set @Statement += @ColumnSubSelections

exec (@Statement)