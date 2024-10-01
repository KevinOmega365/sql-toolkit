
/*
    Transform a sparse table into a key-value table
*/

-------------------------------------------------------------------------------
-----------------------------------------------------------------  Toy Table --
-------------------------------------------------------------------------------

drop table if exists #SparseTable

create table #SparseTable (
    id int,
    a char(1),
    b char(1),
    c char(1)
)
insert into #SparseTable
values
    (1, 'x', '', 'x'),
    (2, 'x', '', ''),
    (3, '', '', ''),
    (4, 'x', 'x', 'x'),
    (5, '', '', 'x')

-------------------------------------------------------------------------------
------------------------------------------------------- Hard-coded transform --
-------------------------------------------------------------------------------

select id, KeyColumn = 'a', a from #SparseTable where a <> '' union all
select id, KeyColumn = 'b', b from #SparseTable where b <> '' union all
select id, KeyColumn = 'c', c from #SparseTable where c <> ''
order by id, KeyColumn

-------------------------------------------------------------------------------
---------------------------------------------------------- Dynamic transform --
-------------------------------------------------------------------------------

declare @dynamicSqlStatement nvarchar(max)
declare @unionAllClause nchar(12) = ' union all '
declare @tableName nvarchar(128) = '#SparseTable'
declare @Columns table (
    name nvarchar(128)
)
insert into @Columns
values
    ('a'),
    ('b'),
    ('c')

select
    @dynamicSqlStatement = string_agg(
        getKeyValueRowSql,
        @unionAllClause
    ) +
    ' order by id, KeyColumn'
from
(
    select
        getKeyValueRowSql =
            'select id, KeyColumn = ''' +
            C.name +
            ''', ' + C.name + ' from ' +
            @tableName +
            ' where ' + C.name + ' <> '''''
    from
        @Columns AS C
) T

execute sp_executesql @dynamicSqlStatement

print @dynamicSqlStatement

-------------------------------------------------------------------------------
------------------------------------------------------------- Original table --
-------------------------------------------------------------------------------

select * from #SparseTable