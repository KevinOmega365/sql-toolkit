declare
    @columnName nvarchar(128) = 'INTEGR_REC_GROUPREF',
    @columnValue nvarchar(128) = '4752565e-84f0-4592-a446-f0720bbc3540',
    @sqlStatement nvarchar(max)

declare @TablesColumnValueCounts table (
    TableName nvarchar(128),
    ValueCount int
)
--

select
    @sqlStatement = string_agg(TableQueries, ' union all ')
from
(
    select
        TableQueries = cast('select TableName = ''' + o.name + ''', ValueCount = (select count(*) from dbo.' + o.name + ' with (nolock) where ' + @columnName + ' = ''' + @columnValue + ''')' as nvarchar(max))
    from
        sys.objects o
        join sys.columns c
            on c.object_id = o.object_id
    where
        o.type = 'u'
        and c.name = @columnName
    group by
        o.name
) T

--

insert into @TablesColumnValueCounts
exec(@sqlStatement)

--

select *
from @TablesColumnValueCounts
where ValueCount > 0