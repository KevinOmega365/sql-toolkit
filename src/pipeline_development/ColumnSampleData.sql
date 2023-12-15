/*
 * Example column data
 */

declare
    @tableName nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents',
    @sampleSize int = 5

declare @PerColumnQueries table (
    sqlStatement nvarchar(max)
)

--------------------------------------------------------------------------------

insert into @PerColumnQueries
select
    'select
        tableName = ''' + @tableName + ''',
        columnName = ''' + name + ''',
        distinctNonnullValues = case
            when (
                select
                    count(*)
                from
                    dbo.' + @tableName + ' with (nolock)
                where
                    ' + name + ' is not null
            ) = 0 then ''''
            when (
                select
                    count(distinct ' + name + ')
                from
                    dbo.' + @tableName + ' with (nolock)
                where
                    ' + name + ' is not null
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