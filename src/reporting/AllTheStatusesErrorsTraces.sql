
-- table list is generated from a single pipeline
declare
    @GroupRef nvarchar(36) = N'564d970e-8b1a-4a4a-913b-51e44d4bd8e7'

-------------------------------------------------------------------------------

declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @tabSpace nchar(4) = '    '

declare
    @columnDefSplitter nchar(7) = ',' + @crlf + @tabSpace -- how many chars...

-------------------------------------------------------------------------------

create table #IntegrationsColumns (
    ColumnName nvarchar(128) collate Latin1_General_CI_AS,
    ColumnOrder tinyint
)
insert into #IntegrationsColumns
values
    ('INTEGR_REC_GROUPREF', 1),
    ('INTEGR_REC_BATCHREF', 2),
    ('INTEGR_REC_STATUS', 3),
    ('INTEGR_REC_ERROR', 4),
    ('INTEGR_REC_TRACE', 5)

-------------------------------------------------------------------------------

-- table list is generated from a single pipeline
select
    TableName = DBObjectID
into
    #ImportTables
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups_Tables T with (nolock)
    join sys.columns C
        on C.object_id = object_id(DBObjectID)
    join #IntegrationsColumns IC
        on IC.ColumnName = C.name
where
    GroupRef = @GroupRef
group by
    DBObjectID
having
    count(*) = (select count(*) from #IntegrationsColumns)

-------------------------------------------------------------------------------

create table #PipelineStatus (
    Count int,
    TableName nvarchar(128),
    INTEGR_REC_GROUPREF UNIQUEIDENTIFIER,
    INTEGR_REC_BATCHREF UNIQUEIDENTIFIER,
    INTEGR_REC_STATUS NVARCHAR(50),
    INTEGR_REC_ERROR NVARCHAR(MAX),
    INTEGR_REC_TRACE NVARCHAR(MAX)
)

-------------------------------------------------------------------------------

select
    SqlStatement =
        'insert into #PipelineStatus' + @crlf +
        'select' + @crlf + @tabSpace +
        'Count = count(*),' + @crlf + @tabSpace + '''' + TableName + ''',' + @crlf + @tabSpace +
        string_agg(ColumnName, @columnDefSplitter) within group (order by ColumnOrder) + @crlf +
        'from' + @crlf + @tabSpace +
        'dbo.' + TableName + ' with (nolock)' + @crlf +
        'group by' + @crlf + @tabSpace +
        string_agg(ColumnName, @columnDefSplitter) within group (order by ColumnOrder) + @crlf
    , TableName
    , ColumnList = string_agg(ColumnName, ', ') within group (order by ColumnOrder)
into
    #SqlStatements
from
    #ImportTables,
    #IntegrationsColumns
group by
    TableName

-------------------------------------------------------------------------------

declare
    @SqlStatement nvarchar(max),
    @TableName nvarchar(128),
    @ColumnList nvarchar(max)

declare sql_load_cursor
cursor for
    select * from #SqlStatements

open sql_load_cursor

fetch next from sql_load_cursor
into
    @SqlStatement,
    @TableName,
    @ColumnList

while @@fetch_status = 0
begin

    exec sp_executesql @SqlStatement

    fetch next from sql_load_cursor
    into
        @SqlStatement,
        @TableName,
        @ColumnList

end

close sql_load_cursor
deallocate sql_load_cursor

-------------------------------------------------------------------------------

select * from #PipelineStatus

-------------------------------------------------------------------------------