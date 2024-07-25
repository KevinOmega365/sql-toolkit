
declare
    @whereEqualsClauses nvarchar(max) = '[
        { "tableAlias": "I", "columnName": "INTEGR_REC_STATUS", "columnValue": "ACTION_UPDATE"},
        { "tableAlias": "I", "columnName": "INTEGR_REC_GROUPREF", "columnValue": "564d970e-8b1a-4a4a-913b-51e44d4bd8e7"}
    ]'
declare
    @sourceTable nvarchar(128) = 'ltbl_Import_DTS_DCS_Documents',
    @sourceTableAlias nvarchar(128) = 'I',
    @destinationTable nvarchar(128) = 'atbl_DCS_Documents',
    @destinationTableAlias nvarchar(128) = 'D',
    @joinColumns nvarchar(max) = '[
        { "sourceColumn" : "DCS_Domain", "destinationColumn" : "Domain" },
        { "sourceColumn" : "DCS_DocumentID", "destinationColumn" : "DocumentID" }
    ]',
    @comparisonColumns nvarchar(max) = '[
        { "sourceColumn" : "DCS_Area", "destinationColumn" : "Area" },
        { "sourceColumn" : "DCS_Classification", "destinationColumn" : "Classification" },
        { "sourceColumn" : "DCS_Confidential", "destinationColumn" : "Confidential" },
        { "sourceColumn" : "DCS_ContractNo", "destinationColumn" : "ContractNo" },
        { "sourceColumn" : "DCS_Criticality", "destinationColumn" : "Criticality" },
        { "sourceColumn" : "DCS_DFO", "destinationColumn" : "DFO" },
        { "sourceColumn" : "DCS_Discipline", "destinationColumn" : "Discipline" },
        { "sourceColumn" : "DCS_DocumentGroup", "destinationColumn" : "DocumentGroup" },
        { "sourceColumn" : "DCS_DocumentType", "destinationColumn" : "DocumentType" },
        { "sourceColumn" : "DCS_FacilityID", "destinationColumn" : "FacilityID" },
        { "sourceColumn" : "DCS_OriginatorCompany", "destinationColumn" : "OriginatorCompany" },
        { "sourceColumn" : "DCS_PlantID", "destinationColumn" : "PlantID" },
        { "sourceColumn" : "DCS_PONumber", "destinationColumn" : "PONumber" },
        { "sourceColumn" : "DCS_ReviewClass", "destinationColumn" : "ReviewClass" },
        { "sourceColumn" : "DCS_System", "destinationColumn" : "System" },
        { "sourceColumn" : "DCS_Title", "destinationColumn" : "Title" },
        { "sourceColumn" : "DCS_VoidedDate", "destinationColumn" : "VoidedDate" },

        { "sourceColumn" : "DCS_ContractorDocumentID", "destinationColumn" : "ContractorDocumentID" },
        
        { "sourceColumn" : "DCS_AssetCustomText1", "destinationColumn" : "AssetCustomText1" },
        { "sourceColumn" : "DCS_DocsCustomFreeText1", "destinationColumn" : "DocsCustomFreeText1" },
        { "sourceColumn" : "DCS_DocsCustomText1", "destinationColumn" : "DocsCustomText1" },
        { "sourceColumn" : "DCS_DocsCustomText2", "destinationColumn" : "DocsCustomText2" },
        { "sourceColumn" : "DCS_DocsCustomText3", "destinationColumn" : "DocsCustomText3" },
        { "sourceColumn" : "DCS_DocsCustomText4", "destinationColumn" : "DocsCustomText4" },
        { "sourceColumn" : "DCS_Flag", "destinationColumn" : "Flag" },
        { "sourceColumn" : "DCS_InstanceCustomText2", "destinationColumn" : "InstanceCustomText2" },
        { "sourceColumn" : "DCS_InstanceCustomText3", "destinationColumn" : "InstanceCustomText3" }
    ]'

-------------------------------------------------------------------------------
    
declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @tab nchar(4) = '    '

declare
    @newLineNewLineUnionAllNewLineNewLine nchar(17) = @crlf + @crlf +'union all' + @crlf + @crlf,
    @newLineTabAnd nchar(10) = @crlf + @tab + 'and ',
    @newLineTabTabAnd nchar(14) = @crlf + @tab + @tab + 'and '

-------------------------------------------------------------------------------

declare @startFrom nvarchar(max) = @crlf + 'from' + @crlf + @tab

declare @joinTables nvarchar(max) =
    'dbo.' +
    @sourceTable +
    ' ' +
    @sourceTableAlias +
    ' with (nolock)' +
    @crlf +
    @tab +
    'join ' +
    'dbo.' +
    @destinationTable +
    ' ' +
    @destinationTableAlias +
    ' with (nolock)' +
    @crlf +
    @tab +
    @tab +
    'on '

declare @joinTablesColumns nvarchar(max) = (
    select string_agg(statement, @newLineTabTabAnd)
    from
        (
            select
                statement =             
                    @destinationTableAlias +
                    '.' +
                    destinationColumn +
                    ' = ' +
                    @sourceTableAlias +
                    '.' +
                    sourceColumn
            from
                (
                    select
                        destinationColumn = json_value(value, '$.destinationColumn'),
                        sourceColumn = json_value(value, '$.sourceColumn')
                    from
                        openjson(@joinColumns)
                ) T
        ) U
)

declare @where nvarchar(max) = 
    @crlf +
    'where' +
    @crlf +
    @tab +
    (
        select string_agg(statement, @newLineTabAnd)
        from
            (
                select
                    statement =
                        tableAlias +
                        '.' +
                        columnName +
                        ' = ''' +
                        columnValue +
                        ''''
                from
                    (
                        select
                            tableAlias = json_value(value, '$.tableAlias'),
                            columnName = json_value(value, '$.columnName'),
                            columnValue = json_value(value, '$.columnValue')
                        from
                            openjson(@whereEqualsClauses)
                    ) T
            ) U
    )

-------------------------------------------------------------------------------

declare @columnChangeCounts nvarchar(max) = (
    select string_agg((
        statement +
        @startFrom +
        @joinTables +
        @joinTablesColumns +
        @where
    ), @newLineNewLineUnionAllNewLineNewLine)
    from
        (
            select
                statement =
                    'select' +
                    @crlf +
                    @tab +
                    'ColummName = ''' +
                    destinationColumn +
                    ''',' +
                    @crlf +
                    @tab +
                    'ChangeCount = sum(case when isnull(' +
                    @destinationTableAlias +
                    '.' +
                    destinationColumn +
                    ', '''') <> isnull(' +
                    @sourceTableAlias +
                    '.' +
                    sourceColumn +
                    ', '''') then 1 else 0 end)'
            from
                (
                    select
                        destinationColumn = json_value(value, '$.destinationColumn'),
                        sourceColumn = json_value(value, '$.sourceColumn')
                    from
                        openjson(@comparisonColumns)
                ) T
        ) U
)

exec
    (@columnChangeCounts)
