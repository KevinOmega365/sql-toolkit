
declare
    @clrf char(2) = char(13) + char(10),
    @tab char(1) = char(9),
    @SqlStatement nvarchar(max) = '',
    @SourceTable nvarchar(128) = 'ltbl_Import_ProArc_Documents',
    @SourceTableAlias nvarchar(128) = 'ImportDocuments',
    @DestinationTable nvarchar(128) = 'atbl_DCS_Documents',
    @DestinationTableAlias nvarchar(128) = 'PimsDocuments',
    @JoinColumns nvarchar(max) = '
        [
            {
                "DestinationTableJoinColum": "Domain",
                "SourceTableJoinColumn": "DCS_Domain"
            },
            {
                "DestinationTableJoinColum": "DocumentID",
                "SourceTableJoinColumn": "document_number"
            },
            {
                "DestinationTableJoinColum": "Revision",
                "SourceTableJoinColumn": "revision"
            }
        ]',
    @JoinColumnsSqlSegment nvarchar(max),
    @UpdateColumns nvarchar(max) = 'todo'

declare
    @JoinConjunction char(8) = @clrf + @tab + @tab + 'and '

----------------------------------------

select
    @JoinColumnsSqlSegment = string_agg(ColumnJoin, @JoinConjunction)
from
    (
        select
            ColumnJoin =
                @DestinationTableAlias + '.' + json_value(value, '$.DestinationTableJoinColum') +
                ' = ' +
                @SourceTableAlias + '.' + json_value(value, '$.SourceTableJoinColumn')
        from
            openjson(@JoinColumns)
    ) JoinExpression

----------------------------------------

set @SqlStatement += 'select' + @clrf
set @SqlStatement += 'from' + @clrf
set @SqlStatement += @tab + 'dbo.' + @SourceTable + ' as ' + @SourceTableAlias + ' with (nolock)' + @clrf
set @SqlStatement += @tab + ' join dbo.' + @DestinationTable + ' as ' + @SourceTableAlias + ' with (nolock)' + @clrf
set @SqlStatement += @tab + @tab + 'on ' + @JoinColumnsSqlSegment + @clrf

select @SqlStatement
