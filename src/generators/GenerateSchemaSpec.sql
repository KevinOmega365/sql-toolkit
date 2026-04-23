/**
 * Generate Schema Spec
 */

declare @TablesAndColumnsJson nvarchar(max) = '[
    {
        "alias": "Groups",
        "tableName": "atbl_TGE_AzureAdGroups",
        "columnNames": [
            "AzureGroupEmail",
            "Name",
            "Description",1
            "Deprecated",
            "ErrorMessage",
            "ErrorStackTrace",
            "LastRun",
            "AzureID"
        ]
    },
    {
        "alias": "Roles",
        "tableName": "atbl_TGE_AzureAdGroupsOrgUnitsRoles",
        "columnNames": [
            "AzureAdGroupsOrgUnits_ID",
            "Role_ID"
        ]
    },
    {
        "alias": "Users",
        "tableName": "atbl_TGE_AzureAdUsers_Staging",
        "columnNames": [
            "AzureID",
            "Email",
            "FirstName",
            "LastName",
            "DisplayName",
            "OfficeLocation",
            "JobTitle",
            "UserPrincipalName",
            "Department",
            "CompanyName",
            "EmployeeType"
        ]
    }
]'

-------------------------------------------------------------------------------

declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @tabSpace nchar(4) = '    '

declare
    @columnDefSplitter nchar(7) = ',' + @crlf + @tabSpace -- how many chars...

-------------------------------------------------------------------------------

select
    Alias = json_value(TableDetails.value, '$.alias'),
    TableName = json_value(TableDetails.value, '$.tableName'),
    ColumnName = ColumnNames.value
into
    #TablesColumns
from
    openjson(@TablesAndColumnsJson) TableDetails
    cross apply openjson(json_query(TableDetails.value, '$.columnNames')) ColumnNames
order by
    Alias,
    ColumnName


-- @tableName nvarchar(128) = 'atbl_TGE_AzureAdGroupsOrgUnitsRoles' -- cruft

-- declare @tempTableName nvarchar(128) = right(@tableName, charindex('_', reverse(@tableName)) - 1)


-------------------------------------------------------------------------------

-- what I need is another level of grouping and aggregatiing

select
    column_id,
    TableName,
    ApiAlias,
    ColumnName,
    ColumnDef = ColumnName + ' ' + upper(ColumnType) + LengthOrPrecision
into #TableColumnDefinitions
from
(
    select
        column_id,
        TableName,
        ApiAlias,
        ColumnName,
        ColumnType,
        LengthOrPrecision = case
            when ColumnType = 'decimal'
                then '(' + cast(ColumnPrecision as nvarchar(max)) + ', ' + cast(ColumnScale as nvarchar(max)) + ')'
            when ColumnType like '%char'
                then '(' + ColumnMaxLength + ')'
            else ''
            end
        -- ,* -- debug
    from
    (
        select
            column_id,
            TableName = TC.TableName,
            ApiAlias = TC.Alias, 
            ColumnName = name,
            ColumnType = type_name(system_type_id),
            ColumnMaxLength =
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
            ColumnPrecision = case
                when type_name(system_type_id) = 'decimal'
                then precision
                else null
                end,
            ColumnScale = case
                when type_name(system_type_id) = 'decimal'
                then scale
                else null
                end
            -- ,* -- debug
        from
            sys.columns C
            join #TablesColumns TC
                on object_id(TC.TableName) = C.object_id
                and TC.ColumnName collate Latin1_General_100_CI_AS_KS_WS_SC = C.name
    ) T
) U

-------------------------------------------------------------------------------


select
    stmt = ApiAlias collate Latin1_General_100_CI_AS_KS_WS_SC +  ' (' + @crlf +
    @tabSpace + 
    string_agg(ColumnDef, @columnDefSplitter)
        within group (order by ColumnName)  + -- column_id
    @crlf + ')'
from
    #TableColumnDefinitions
group by
    TableName,
    ApiAlias


-- select
--     SqlDef =
--         @tempTableName + ' (' + @crlf +
--         @tabSpace + @ColumnDefinitionString + @crlf +
--         ')'