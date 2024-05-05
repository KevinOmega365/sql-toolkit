declare
    @groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @action_update nvarchar(128) = 'ACTION_UPDATE',
    @dateFormat int = 105

declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @tab nchar(4) = '    '

declare
    @commaNewLineTab nchar(7) = ',' + @crlf + @tab,
    @newLineTabTabAnd nchar(14) = @crlf + @tab + @tab + 'and '

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
        { "sourceColumn" : "DCS_Title", "destinationColumn" : "Title" },
        { "sourceColumn" : "DCS_PlantID", "destinationColumn" : "PlantID" },
        { "sourceColumn" : "DCS_OriginatorCompany", "destinationColumn" : "OriginatorCompany" },
        { "sourceColumn" : "DCS_FacilityID", "destinationColumn" : "FacilityID" },
        { "sourceColumn" : "DCS_DocumentType", "destinationColumn" : "DocumentType" },
        { "sourceColumn" : "DCS_DocumentGroup", "destinationColumn" : "DocumentGroup" },
        { "sourceColumn" : "DCS_Discipline", "destinationColumn" : "Discipline" },
        { "sourceColumn" : "DCS_ContractNo", "destinationColumn" : "ContractNo" },
        { "sourceColumn" : "DCS_Criticality", "destinationColumn" : "Criticality" },
        { "sourceColumn" : "DCS_Comments", "destinationColumn" : "Comments" },
        { "sourceColumn" : "DCS_Area", "destinationColumn" : "Area" },
        { "sourceColumn" : "DCS_Confidential", "destinationColumn" : "Confidential" },
        { "sourceColumn" : "DCS_Classification", "destinationColumn" : "Classification" },
        { "sourceColumn" : "DCS_PONumber", "destinationColumn" : "PONumber" },
        { "sourceColumn" : "DCS_System", "destinationColumn" : "System" },
        { "sourceColumn" : "DCS_VoidedDate", "destinationColumn" : "VoidedDate" },
        { "sourceColumn" : "DCS_ReviewClass", "destinationColumn" : "ReviewClass" }
    ]'

declare @startSelect nvarchar(max) = 'select' + @crlf + @tab

/**
 * ex: Title = sum(case when isnull(D.Title, '') <> isnull(I.DCS_Title, '') then 1 else 0 end)
 */
declare @columnChangeCounts nvarchar(max) = (
    select string_agg(statement, @commaNewLineTab)
    from
        (
            select
                statement = 
                    destinationColumn +
                    ' = sum(case when isnull(' +
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
    'INTEGR_REC_STATUS = ''' +
    @action_update +
    '''' +
    @crlf +
    @tab +
    ' and INTEGR_REC_GROUPREF = ''' +
    cast(@groupRef as nchar(36)) +
    ''''

select
    (@startSelect +
    @columnChangeCounts +
    @startFrom +
    @joinTables +
    @joinTablesColumns +
    @where)

/**
 * Change counts
 */
/*
select
    Title = sum(case when isnull(D.Title, '') <> isnull(I.DCS_Title, '') then 1 else 0 end),
    PlantID = sum(case when isnull(D.PlantID, '') <> isnull(I.DCS_PlantID, '') then 1 else 0 end),
    OriginatorCompany = sum(case when isnull(D.OriginatorCompany, '') <> isnull(I.DCS_OriginatorCompany, '') then 1 else 0 end),
    FacilityID = sum(case when isnull(D.FacilityID, '') <> isnull(I.DCS_FacilityID, '') then 1 else 0 end),
    DocumentType = sum(case when isnull(D.DocumentType, '') <> isnull(I.DCS_DocumentType, '') then 1 else 0 end),
    DocumentGroup = sum(case when isnull(D.DocumentGroup, '') <> isnull(I.DCS_DocumentGroup, '') then 1 else 0 end),
    Discipline = sum(case when isnull(D.Discipline, '') <> isnull(I.DCS_Discipline, '') then 1 else 0 end),
    ContractNo = sum(case when isnull(D.ContractNo, '') <> isnull(I.DCS_ContractNo, '') then 1 else 0 end),
    Criticality = sum(case when isnull(D.Criticality, '') <> isnull(I.DCS_Criticality, '') then 1 else 0 end),
    Comments = sum(case when isnull(D.Comments, '') <> isnull(I.DCS_Comments, '') then 1 else 0 end),
    Area = sum(case when isnull(D.Area, '') <> isnull(I.DCS_Area, '') then 1 else 0 end),
    Confidential = sum(case when isnull(D.Confidential, '') <> isnull(I.DCS_Confidential, '') then 1 else 0 end),
    Classification = sum(case when isnull(D.Classification, '') <> isnull(I.DCS_Classification, '') then 1 else 0 end),
    PONumber = sum(case when isnull(D.PONumber, '') <> isnull(I.DCS_PONumber, '') then 1 else 0 end),
    System = sum(case when isnull(D.System, '') <> isnull(I.DCS_System, '') then 1 else 0 end),
    VoidedDate = sum(case when isnull(D.VoidedDate, '') <> isnull(I.DCS_VoidedDate, '') then 1 else 0 end),
    ReviewClass = sum(case when isnull(D.ReviewClass, '') <> isnull(I.DCS_ReviewClass, '') then 1 else 0 end)
from
    dbo.ltbl_Import_MuninAibel_Documents I with (nolock)
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = I.DCS_Domain
        and D.DocumentID = I.DCS_DocumentID
where
    INTEGR_REC_STATUS = @action_update
    and INTEGR_REC_GROUPREF = @groupRef
*/