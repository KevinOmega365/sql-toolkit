/**
 * Generate Temp Table Definition
 */

declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @tabSpace nchar(4) = '    ',
    @tableName nvarchar(128) = 'atbl_Integrations_Configurations_FieldMappingSets_Subscribers'

declare @tempTableName nvarchar(128) = right(@tableName, charindex('_', reverse(@tableName)) - 1)

declare @columnDefSplitter nchar(7) = ',' + @crlf + @tabSpace -- how many characters...

-------------------------------------------------------------------------------

select
    column_id,
    ColumnDef = ImportColumnName + ' ' + upper(ImportColumnType) + LengthOrPrecision
into #ColumnDefinitions
from
(
    select
        column_id,
        ImportColumnName,
        ImportColumnType,
        LengthOrPrecision = case
            when ImportColumnType = 'decimal'
                then '(' + cast(ImportColumnPrecision as nvarchar(max)) + ', ' + cast(ImportColumnScale as nvarchar(max)) + ')'
            when ImportColumnType like '%char'
                then '(' + ImportColumnMaxLength + ')'
            else ''
            end
        -- ,* -- debug
    from
    (
        select
            column_id,
            ImportColumnName = name,
            ImportColumnType = type_name(system_type_id),
            ImportColumnMaxLength =
                case
                when type_name(system_type_id) like '%char'
                    then case
                            when max_length = -1
                                then 'MAX'
                        when type_name(system_type_id) like 'n%'
                                then cast(max_length / 2 as nvarchar(max))
                            else
                                cast(max_length as nvarchar(max))
                        end
                else null
                end,
            ImportColumnPrecision = case
                when type_name(system_type_id) = 'decimal'
                then precision
                else null
                end,
            ImportColumnScale = case
                when type_name(system_type_id) = 'decimal'
                then scale
                else null
                end
            -- ,* -- debug
        from
            sys.columns Columns
        where
            object_id = object_id(@tableName)
    ) T
) U

-------------------------------------------------------------------------------

declare @ColumnDefinitionString nvarchar(max) = (
    select
        string_agg(ColumnDef, @columnDefSplitter)
            within group (order by column_id)
    from
        #ColumnDefinitions
)

select
    SqlDef =
        'drop table if exists #' + @tempTableName + @crlf +
        'create table #' + @tempTableName + ' (' + @crlf +
        @tabSpace + @ColumnDefinitionString + @crlf +
        ')'
