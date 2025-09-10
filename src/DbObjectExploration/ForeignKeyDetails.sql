/*
 * FKs referencing a table
 */
-- declare @TableName SYSNAME = 'stbl_System_Companies';
-- select
--     ForeignKeyName = fk.name,
--     ReferencingTable = tp.name,
--     ReferencingColumn = cp.name,
--     ReferencedTable = tr.name,
--     ReferencedColumn = cr.name
-- from
--     sys.foreign_keys fk
--     inner join sys.foreign_key_columns fkc
--         on fkc.constraint_object_id = fk.object_id
--     inner join sys.tables tp
--         on tp.object_id = fkc.parent_object_id
--     inner join sys.columns cp
--         on cp.column_id = fkc.parent_column_id
--     and cp.object_id = tp.object_id
--     inner join sys.tables tr
--         on tr.object_id = fkc.referenced_object_id
--     inner join sys.columns cr
--         on cr.column_id = fkc.referenced_column_id
--     and cr.object_id = tr.object_id
-- where
--     tr.name = @TableName
-- order by
--     tp.name,
--     fk.name

/*
 * FK detail from table-column
 */
declare @TableName SYSNAME = 'atbl_Arena_Documents';
declare @ColumnName SYSNAME = 'ReviewClass_ID';
select
    ForeignKeyName = fk.name,
    ReferencingTable = tp.name,
    ReferencingColumn = cp.name,
    ReferencedTable = tr.name,
    ReferencedColumn = cr.name
from
    sys.foreign_keys fk
    inner join sys.foreign_key_columns fkc
        on fkc.constraint_object_id = fk.object_id
    inner join sys.tables tp
        on tp.object_id = fkc.parent_object_id
    inner join sys.columns cp
        on cp.column_id = fkc.parent_column_id
    and cp.object_id = tp.object_id
    inner join sys.tables tr
        on tr.object_id = fkc.referenced_object_id
    inner join sys.columns cr
        on cr.column_id = fkc.referenced_column_id
    and cr.object_id = tr.object_id
where
    tp.name = @TableName
    and cp.name = @ColumnName
order by
    tp.name,
    fk.name
