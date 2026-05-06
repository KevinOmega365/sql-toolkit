
/**
 * Generate Add Column Statements
 */
declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @sinkTableName nvarchar(128) = 'ltbl_Import_TIF_PersonsPositions',
    @columnNamingPrefix nvarchar(8) = '',
    @columnList nvarchar(max) = '[
        "Company_Personnel_Number",
        "Company",
        "Company_Email",
        "First_Name",
        "Last_Name",
        "Mob_Position",
        "Location",
        "Pims_Domain",
        "Pims_Project",
        "Pims_Position_Type",
        "Pims_Disciplines",
        "Pims_Delivery_Lines",
        "Start_Date",
        "Departure_time",
        "End_Date",
        "Vendor",
        "Discipline_Code",
        "Disciplinedf",
        "Description_Ext"
    ]'

select
    Statement = -- significant whitespace
'    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''' + @sinkTableName + ''' AND COLUMN_NAME = ''' + ImportColumnName + ''')
    BEGIN
        ALTER TABLE ' + @sinkTableName + ' ADD [' + ImportColumnName + '] ' + upper(ImportColumnType) + LengthOrPrecision + ' NULL;
    END;'
    -- ,* -- debug
from 
(
    select
        ImportColumnName,
        ImportColumnType,
        LengthOrPrecision = '(' + ImportColumnMaxLength + ')'
        -- ,* -- debug
    from
    (
        select
            ImportColumnName = @columnNamingPrefix + ColumnList.value,
            ImportColumnType = 'NVARCHAR',
            ImportColumnMaxLength = 'MAX',
            ImportColumnPrecision = null,
            ImportColumnScale = null,* -- debug
        from
            openjson(@columnList) ColumnList
    ) T
) U

/**
 * Reference
 */
-- select *
-- from sys.columns Columns
-- where object_id = object_id(@sourceTableName)
