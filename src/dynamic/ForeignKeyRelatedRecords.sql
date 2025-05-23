DECLARE @tableName NVARCHAR(128) = 'atbl_DCS_Documents'
DECLARE @Domain NVARCHAR(128) = '175'
DECLARE @DocumentID NVARCHAR(128) = 'UPP-AIL-I-RA-01002'

SELECT
    sql_count_statement = select_count + ' ' + from_tables + ' ' + columm_predicate + ' ' + where_clause + ' union all'
    -- sql_select_statement = 'select P.* ' + from_tables + ' ' + columm_predicate + ' ' + where_clause
FROM
    (
        SELECT
            select_count = 'select Name = ''' + foreign_key + ''', Count = count(*)',
            from_tables = 'from dbo.' + referenced_object + ' R with (nolock) join dbo.' + parent_object + ' P with (nolock)',
            columm_predicate = 'on ' + STRING_AGG(
                'P.' + parent_column + ' = R.' + referenced_column,
                ' and '
            ) WITHIN GROUP (
                ORDER BY
                    constraint_column_id
            ),
            where_clause = 'where R.Domain = ''' + @Domain + ''' and R.DocumentID = ''' + @DocumentID + ''''
        FROM
            (
                SELECT
                    foreign_key = OBJECT_NAME(f.object_id),
                    parent_object = OBJECT_NAME(f.parent_object_id),
                    referenced_object = OBJECT_NAME(f.referenced_object_id),
                    parent_column = COL_NAME(fc.parent_object_id, fc.parent_column_id),
                    referenced_column = COL_NAME(fc.referenced_object_id, fc.referenced_column_id),
                    constraint_column_id
                FROM
                    sys.foreign_keys AS f
                    JOIN sys.foreign_key_columns AS fc ON f.object_id = fc.constraint_object_id
                WHERE
                    OBJECT_NAME(f.referenced_object_id) = 'atbl_DCS_Documents' -- @tableName
            ) T
        GROUP BY
            foreign_key,
            parent_object,
            referenced_object
    ) U
