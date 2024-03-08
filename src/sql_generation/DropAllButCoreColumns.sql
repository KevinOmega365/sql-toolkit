-- select
--     name
--     , type
-- from
--     sys.objects
-- where
--     name like '%dts_dcs%'
--     and name not like '%raw'
--     and type in ('U') -- 'V', 'P'
--     -- and type not in ('UQ', 'D')

select
    sqlStatement = 'ALTER TABLE [' + o.name + '] DROP COLUMN [' + c.name + '];'
    , TableName = o.name
    , ColumnName = c.name
    , ColumnID = c.column_id
from
    sys.objects o
    join sys.columns c
        on o.object_id = c.object_id
where
    o.name in (
        'ltbl_Import_DTS_DCS_Documents',
        'ltbl_Import_DTS_DCS_Revisions',
        'ltbl_Import_DTS_DCS_RevisionsFiles'
    )
    -- and c.name not in (
    --     'CDL',
    --     'Created',
    --     'CreatedBy',
    --     'CUT',
    --     'INTEGR_REC_BATCHREF',
    --     'INTEGR_REC_ERROR',
    --     'INTEGR_REC_GROUPREF',
    --     'INTEGR_REC_STATUS',
    --     'INTEGR_REC_TRACE',
    --     'JsonRow',
    --     'PrimKey',
    --     'Updated',
    --     'UpdatedBy'
    -- )
order by
    TableName,
    ColumnID