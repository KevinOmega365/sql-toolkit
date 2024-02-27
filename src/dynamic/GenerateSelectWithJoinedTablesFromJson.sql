
--

/**
 * Generate select with joined tables from JSON
 */

-- NB: Array ordering for keys is PROBLEMATIC.
declare @JoinJson nvarchar(max) = '{
    "tables": [
        {
            "name": "ltbl_Import_Widgets",
            "alias": "IW"
        },
        {
            "name": "atbl_QUX_Widgets",
            "alias": "PW"
        }
    ],
    "joinColumns": [
        {
            "name": "Domain",
            "table": 1,
            "counterpart": 1
        },
        {
            "name": "QUX_Domain",
            "table": 0,
            "counterpart": 0
        },
        {
            "name": "WidgetID",
            "table": 1,
            "counterpart": 3
        },
        {
            "name": "QUX_WidgetID",
            "table": 0,
            "counterpart": 2
        },
        {
            "name": "Version",
            "table": 1,
            "counterpart": 5
        },
        {
            "name": "QUX_Version",
            "table": 0,
            "counterpart": 4
        }
    ]
}'

declare @SqlStatemnet nvarchar(max) = ''

--

set @SqlStatemnet = @SqlStatemnet + (
    select string_agg(JoinTable, ' join ')
    from
    (
        select
            JoinTable = 
                'dbo.'
                + json_value(value, '$.name')
                + ' '
                + json_value(value, '$.alias')
                + ' with (nolock)' 
        from
            openjson(@JoinJson, '$.tables')
    ) TableList
)

set @SqlStatemnet = @SqlStatemnet
    + ' on '
    + (
        select string_agg(OnColumns, ' and ')
        from
        (

            select
                OnColumns =
                    (
                        select json_value(value, '$.alias') from openjson(@JoinJson, '$.tables') where [key] = TableKey
                    )
                    + '.'
                    + ColumnName
                    + ' = '
                    + (
                        select json_value(value, '$.alias') from openjson(@JoinJson, '$.tables') where [key] = (
                            select json_value(value, '$.table') from openjson(@JoinJson, '$.joinColumns') where [key] = OtherColumnkey
                        )
                    )
                    + '.'
                    + (
                        select json_value(value, '$.name') from openjson(@JoinJson, '$.joinColumns') where [key] = OtherColumnkey
                    )
                -- ,*
            from
            (
                select
                    ColumnKey = [key],
                    ColumnName = json_value(value, '$.name'),
                    TableKey = json_value(value, '$.table'),
                    OtherColumnKey = json_value(value, '$.counterpart')
                from
                    openjson(@JoinJson, '$.joinColumns')
            ) JoinColumns
            where
                TableKey = 1

        ) JoinColumnList
    )

--

set @SqlStatemnet =
    'select count(*) from '
    + @SqlStatemnet

--

print(@SqlStatemnet)

--
