
/**
 * Generate Add Column Statements
 */
declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @sourceTableName nvarchar(128) = 'atbl_DCS_Documents',
    @sinkTableName nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents',
    @columnNamingPrefix nvarchar(8) = 'DCS_'
    @columnList nvarchar(max) = '[
        "ProgressWeight",
        "Area",
        "AssetCustomText1",
        "Comments",
        "ContractNo",
        "ContractorDocumentID",
        "Criticality",
        "DFO",
        "Discipline",
        "DocsCustomText1",
        "DocsCustomText2",
        "DocsCustomText3",
        "DocsCustomText4",
        "DocumentGroup",
        "DocumentID",
        "DocumentType",
        "Domain",
        "FacilityID",
        "Flag",
        "Import_ExternalUniqueRef",
        "InstanceCustomText2",
        "InstanceCustomText3",
        "OriginatorCompany",
        "PlantID",
        "PONumber",
        "System",
        "Title"
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
            ImportColumnName = @columnNamingPrefix + name,
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
            join openjson(@columnList) ColumnList
                on ColumnList.value = Columns.name
        where
            object_id = object_id(@sourceTableName)
    ) T
) U

/**
 * Reference
 */
-- select *
-- from sys.columns Columns
-- where object_id = object_id(@sourceTableName)