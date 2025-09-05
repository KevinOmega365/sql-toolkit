
declare @tableNamePattern nvarchar(128) = '%arena%propert%'

declare @sql nvarchar(max)

select @sql = (
    select string_agg(sqlQuery, ' union all ') within group (order by sqlQuery) 
    from (
        select sqlQuery =
            'select
                TableName = ''' + name + ''',
                Count = (select count(*)
            from
                dbo.' + name + ')'
        from
            sys.objects
        where
            name like @tableNamePattern
            and type = 'u'
    ) T
)

exec (@sql)
