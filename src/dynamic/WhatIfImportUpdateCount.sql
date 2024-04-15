
/******************************************************************************

Get the number of records that would be updated

******************************************************************************/

-------------------------------------------------------------------------------
----------------------------------------------------------------- Parameters --
-------------------------------------------------------------------------------

/**
 * Parameter passed into sp_executesql
 */
declare
    @Domain nvarchar(128) = '175'

/**
 * Parameters to build SQL
 */
declare
    @sourceTable nvarchar(128) = 'ltbl_Import_MuninAibel_Documents',
    @destinationTable nvarchar(128) = 'atbl_DCS_Documents',
    @joinColumns nvarchar(max) = '[
        { "destination":"Domain", "source": "DCS_Domain" },
        { "destination":"DocumentID", "source": "DCS_DocumentID" }
    ]',
    @updateColumns nvarchar(max) = '[
        { "destination": "Title", "source": "DCS_Title" },
        { "destination": "PlantID", "source": "DCS_PlantID" },
        { "destination": "OriginatorCompany", "source": "DCS_OriginatorCompany" },
        { "destination": "FacilityID", "source": "DCS_FacilityID" },
        { "destination": "DocumentType", "source": "DCS_DocumentType" },
        { "destination": "DocumentGroup", "source": "DCS_DocumentGroup" },
        { "destination": "Discipline", "source": "DCS_Discipline" },
        { "destination": "ContractNo", "source": "DCS_ContractNo" },
        { "destination": "Criticality", "source": "DCS_Criticality" },
        { "destination": "Area", "source": "DCS_Area" },
        { "destination": "Confidential", "source": "DCS_Confidential" },
        { "destination": "Classification", "source": "DCS_Classification" },
        { "destination": "PONumber", "source": "DCS_PONumber" },
        { "destination": "System", "source": "DCS_System" },
        { "destination": "VoidedDate", "source": "DCS_VoidedDate" },
        { "destination": "ReviewClass", "source": "DCS_ReviewClass" }
    ]'

/**
 * String construction constants
 */
declare
    @crlf nchar(2) = CHAR(13)+CHAR(10),
    @And nchar(5) =' AND ',
    @Or nchar(5) =' OR '

-------------------------------------------------------------------------------
--------------------------------------------------------------- Generate SQL --
-------------------------------------------------------------------------------

declare @joinOnColumns nvarchar(max) = (
    select string_agg(Predicate, @And) 
    from
    (
        select
            Predicate =
                '[Destination].['
                + json_value(value, '$.destination')
                + '] = [Source].['
                + json_value(value, '$.source')
                + ']'
        from
            openjson(@joinColumns)
    ) JoinPredicates
)

declare @whereSearchColumns nvarchar(max) = (
    select string_agg(Predicate, @Or)
    from
    (
        select
            Predicate =
                'ISNULL([Destination].['
                + json_value(value, '$.destination')
                + '], '''') <> ISNULL([Source].['
                + json_value(value, '$.source')
                + '], '''')'
        from
            openjson(@updateColumns)
    ) WherePredicates
)

declare @SqlStatement nvarchar(max) = 'SELECT COUNT(*)
FROM [dbo].['+ @sourceTable + '] [Source] WITH (NOLOCK)
JOIN [dbo].[' + @destinationTable + '] [Destination] WITH (NOLOCK)
    ON ' + @crlf + @joinOnColumns + @crlf
+ 'WHERE (' + @whereSearchColumns  + ')
AND Domain = @Domain'

select @SqlStatement

-- exec sp_executesql
--     @SqlStatement,
--     N'@Domain nvarchar(128)',
--     @Domain = @Domain