declare
    @TableName nvarchar(128) = 'atbl_WorkOrders_WorkOrdersEstimates'

select
    ColumnName = name,
    ColumnType = type_name(system_type_id),
    StringColumnMaxLength =
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
    DecimalColumnPrecision = case
        when type_name(system_type_id) = 'decimal'
        then precision
        else null
        end,
    DecimalColumnScale = case
        when type_name(system_type_id) = 'decimal'
        then scale
        else null
        end
    -- ,* -- debug
from
    sys.columns Columns
where
    object_id = object_id(@TableName)