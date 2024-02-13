
DROP TABLE IF EXISTS #SomeTable;
DROP TABLE IF EXISTS #Staging;
DROP TABLE IF EXISTS #Actions;

--------------------------------------------------------------------------------

CREATE TABLE #Actions (
    id int,
    action nvarchar(max)
)
--------------------------------------------------------------------------------

CREATE TABLE #SomeTable (
    item_no int,
    sink_a char(1),
    sink_b char(1),
    sink_c char(1)
)
insert into #SomeTable
values
    (1, 'x', 'y', 'z'),
    (2, 'a', 'b', 'c'),
    (3, 'm', 'n', 'o')

--------------------------------------------------------------------------------

CREATE TABLE #Staging (
    id int,
    src_a char(1),
    src_b char(1),
    src_c char(1),
    action nvarchar(max)
)
insert into #Staging
values
    (1, 'x', 'w', 'z', null),
    (2, 'a', 'b', 'c', null),
    (3, 'q', 'u', 'x', null)

--------------------------------------------------------------------------------

insert into #Actions
select
    Staging.id,
    action = '{"update": [ ' + string_agg(UpdateColumns.UpdateColumnSourcSink, ', ') + ' ]}'
from
    #Staging Staging
    join #SomeTable SomeTable
        on SomeTable.item_no = Staging.id
    join (
        select StagingCompare.id, UpdateColumnSourcSink = case when StagingCompare.src_a <> SomeTableCompare.sink_a then '{ "source": "src_a", "sink": "sink_a" }' else null end from #Staging StagingCompare join #SomeTable SomeTableCompare on SomeTableCompare.item_no = StagingCompare.id union all
        select StagingCompare.id, UpdateColumnSourcSink = case when StagingCompare.src_b <> SomeTableCompare.sink_b then '{ "source": "src_b", "sink": "sink_b" }' else null end from #Staging StagingCompare join #SomeTable SomeTableCompare on SomeTableCompare.item_no = StagingCompare.id union all
        select StagingCompare.id, UpdateColumnSourcSink = case when StagingCompare.src_c <> SomeTableCompare.sink_c then '{ "source": "src_c", "sink": "sink_c" }' else null end from #Staging StagingCompare join #SomeTable SomeTableCompare on SomeTableCompare.item_no = StagingCompare.id
    ) UpdateColumns
        on UpdateColumns.id = Staging.id
where 
    Staging.src_a <> SomeTable.sink_a
    or Staging.src_b <> SomeTable.sink_b
    or Staging.src_c <> SomeTable.sink_c
group by
    Staging.id

--------------------------------------------------------------------------------

update #Staging
set action = Actions.action
from
    #Staging Staging
    join #Actions Actions
        on Staging.id = Actions.id

--------------------------------------------------------------------------------

-- todo: do the updates here DYNAMICALLY
update #SomeTable set [sink_b] = [src_b] from #SomeTable sink join #Staging src on sink.item_no = src.id where src.id = 1
update #SomeTable set [sink_a] = [src_a], [sink_b] = [src_b], [sink_c] = [src_c] from #SomeTable sink join #Staging src on sink.item_no = src.id where src.id = 3

--------------------------------------------------------------------------------

select * from #SomeTable

--------------------------------------------------------------------------------

select
    SqlUpdateStatement =
        'update #SomeTable set '
        + string_agg(
            '[' + json_value(ColumnsToUpdate.value, '$.sink') + ']'
            + ' = '
            + '[' + json_value(ColumnsToUpdate.value, '$.source') + ']'
        , ', ')
        + ' from #SomeTable sink join #Staging src on sink.item_no = src.id where src.id = '
        + cast(Staging.id as nvarchar(max))
from
    #Staging Staging
    cross apply openjson(Staging.action, '$.update') ColumnsToUpdate
where
    action is not null
group by
    Staging.id

--------------------------------------------------------------------------------

select * from #Staging

--------------------------------------------------------------------------------
