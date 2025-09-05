/*
 * Example column data
 */

drop table if exists #dataCoverageReport
create table #dataCoverageReport (
    tableName nvarchar(128),
    columnName nvarchar(128),
    dataCoveragePercent nvarchar(64),
    dataCoverageRatio nvarchar(64),
    distinctNonnullValues nvarchar(max)
)

declare
    @tableName nvarchar(128) = 'atbl_Arena_DocumentsProperties',
    @sampleSize int = 5,
    @percentagePrecision nvarchar(2) = 'P'

--------------------------------------------------------------------------------

declare
    @totalRowCount int,
    @totalRowCountString nvarchar(max),
    @getTotalRowCount nvarchar(max) = 
        'select @n = count(*)
        from dbo.' + @tableName + ' with (nolock)'
exec sp_executesql
    @getTotalRowCount,
    N'@n int out',
    @totalRowCount out
set @totalRowCountString = cast(@totalRowCount as nvarchar(max))

declare @PerColumnQueries table (
    columnId int,
    sqlStatement nvarchar(max)
)

--------------------------------------------------------------------------------

insert into @PerColumnQueries (
    columnId,
    sqlStatement
)
select
    column_id,
    'insert into #dataCoverageReport (
        tableName,
        columnName,
        dataCoveragePercent,
        dataCoverageRatio,
        distinctNonnullValues
    )
    select
        tableName = ''' + @tableName + ''',
        columnName = ''' + name + ''',
        dataCoveragePercent =
            format(
                (
                    select count(*)
                    from dbo.' + @tableName + ' with (nolock)
                    where [' + name + '] is not null
                )
                / ' + @totalRowCountString + '.0,
                ''' + @percentagePrecision + '''
            ),
        dataCoverageRatio =
            cast(
                (
                    select count(*)
                    from dbo.' + @tableName + ' with (nolock)
                    where [' + name + '] is not null
                )
                as nvarchar(max)
            )
            + '' / ''
            + cast(' + @totalRowCountString + ' as nvarchar(max)),
        distinctNonnullValues = case
            when (
                select
                    count(*)
                from
                    dbo.' + @tableName + ' with (nolock)
                where
                    [' + name + '] is not null
            ) = 0 then ''''
            when (
                select
                    count(distinct [' + name + '])
                from
                    dbo.' + @tableName + ' with (nolock)
                where
                    [' + name + '] is not null
            ) > ' + cast(@sampleSize as nvarchar(2)) + ' then (
                select
                    string_agg(cast([' + name + '] as nvarchar(max)), '', '')
                from
                    (
                        select
                            top ' + cast(@sampleSize as nvarchar(2)) + ' [' + name + ']
                        from (
                                select distinct
                                    [' + name + ']
                                from
                                    dbo.' + @tableName + '
                                with
                                    (nolock)
                                where
                                    [' + name + '] is not null
                            ) T
                        order by
                            newid()
                    ) U
            ) + ''...''
            else (
                select
                    string_agg(cast([' + name + '] as nvarchar(max)), '', '')
                from
                    (
                        select distinct
                            [' + name + ']
                        from
                            dbo.' + @tableName + '
                        with
                            (nolock)
                        where
                            [' + name + '] is not null
                    ) T
            )
        end'
from
    sys.columns
where
    object_id = object_id(@tableName)

--------------------------------------------------------------------------------

declare @query nvarchar(max)

declare @i int = 1
declare @n int = (select max(columnId) from @PerColumnQueries)
while @i <= @n
begin
    select @query = sqlStatement from @PerColumnQueries where columnId = @i
    ---------------
    -- print @query
    exec (@query)
    ---------------
    set @i = @i + 1
end

select * from #dataCoverageReport
