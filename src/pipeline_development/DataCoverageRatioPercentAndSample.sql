/*
 * Example column data
 */

declare
    @tableName nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents',
    @sampleSize int = 5,
    @percentagePrecision nvarchar(2) = 'P'
    @GroupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'

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
    sqlStatement nvarchar(max)
)

--------------------------------------------------------------------------------

insert into @PerColumnQueries
select
    'select
        tableName = ''' + @tableName + ''',
        columnName = ''' + name + ''',
        dataCoveragePercent =
            format(
                (
                    select count(*)
                    from dbo.' + @tableName + ' with (nolock)
                    where ' + name + ' is not null
                    and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
                )
                / ' + @totalRowCountString + '.0,
                ''' + @percentagePrecision + '''
            ),
        dataCoverageRatio =
            cast(
                (
                    select count(*)
                    from dbo.' + @tableName + ' with (nolock)
                    where ' + name + ' is not null
                    and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
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
                    ' + name + ' is not null
                    and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
            ) = 0 then ''''
            when (
                select
                    count(distinct ' + name + ')
                from
                    dbo.' + @tableName + ' with (nolock)
                where
                    ' + name + ' is not null
                    and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
            ) > ' + cast(@sampleSize as nvarchar(2)) + ' then (
                select
                    string_agg(' + name + ', '', '')
                from
                    (
                        select
                            top ' + cast(@sampleSize as nvarchar(2)) + ' ' + name + '
                        from (
                                select distinct
                                    ' + name + '
                                from
                                    dbo.' + @tableName + '
                                with
                                    (nolock)
                                where
                                    ' + name + ' is not null
                                    and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
                            ) T
                        order by
                            newid()
                    ) U
            ) + ''...''
            else (
                select
                    string_agg(' + name + ', '', '')
                from
                    (
                        select distinct
                            ' + name + '
                        from
                            dbo.' + @tableName + '
                        with
                            (nolock)
                        where
                            ' + name + ' is not null
                            and INTEGR_REC_GROUPREF = ''' + cast(@GroupRef as nchar(36)) + '''
                    ) T
            )
        end'
from
    sys.columns
where
    object_id = object_id(@tableName)
    and type_name(system_type_id) <> 'uniqueidentifier'

--------------------------------------------------------------------------------

declare @query nvarchar(max) = (select string_agg(sqlStatement, ' union all ') from @PerColumnQueries)

exec (@query)
