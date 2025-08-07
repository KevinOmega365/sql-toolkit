CREATE OR ALTER FUNCTION [dbo].[lfnc_Import_DTS_DCS_FieldMappings_GetSql_SetValue] (
    @BatchRef UNIQUEIDENTIFIER,
    @MappingSetJson NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    /*
        Some sticky points
        1. In the generation of CASE WHEN-THENs IFF is used. The first
           condition after the WHEN should be tabbed in. Otherwise there will
           be a preceding AND and a single space is needed.

        2. The STRING_AGG separators use a tricksy mix of @tabs, @crlfs and
            ''''s. It's not only-only to get the character count right in your
            head.
    */

    DECLARE @IMPORTED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID = 'IMPORTED_OK') -- Transition in/out

    DECLARE @sqlStatement NVARCHAR(MAX)

    /*
    * SQL Formatting
    */
    DECLARE
        @crlf CHAR(2) = CHAR(13) + CHAR(10),
        @tab CHAR(4) = '    '

    DECLARE
        @tab_2 CHAR(8) = @tab + @tab,
        @tab_3 CHAR(12) = @tab + @tab + @tab,
        @tab_4 CHAR(16) = @tab + @tab + @tab + @tab

    ---------------------------------------------------------------------------
    ----------------- Create temp tables to hold mappings and SQL statements --
    ---------------------------------------------------------------------------

    DECLARE @temp_mappings
    TABLE (
        PriorityOrder INT,
        MappingSetID NVARCHAR(128),
        TargetTable NVARCHAR(128),
        CriteriaField1 NVARCHAR(128),
        CriteriaValue1 NVARCHAR(128),
        CriteriaField2 NVARCHAR(128),
        CriteriaValue2 NVARCHAR(128),
        FromField NVARCHAR(128),
        FromValue NVARCHAR(128),
        ToField NVARCHAR(128),
        ToValue NVARCHAR(128),
        MappingType NVARCHAR(128),
        Required BIT
    );

    ---------------------------------------------------------------------------
    ----------------------------------- Populate temp table to hold mappings --
    ---------------------------------------------------------------------------

    INSERT INTO @temp_mappings
    (
            PriorityOrder,
            MappingSetID,
            TargetTable,
            CriteriaField1,
            CriteriaValue1,
            CriteriaField2,
            CriteriaValue2,
            FromField,
            FromValue,
            ToField,
            ToValue,
            MappingType,
            Required
    )
    SELECT *
    FROM OPENJSON (@MappingSetJson)
    WITH
    (
        PriorityOrder INT '$.PriorityOrder',
        MappingSetID NVARCHAR(128) '$.MappingSetID',
        TargetTable NVARCHAR(128) '$.TargetTable',
        CriteriaField1 NVARCHAR(128) '$.CriteriaField1',
        CriteriaValue1 NVARCHAR(128) '$.CriteriaValue1',
        CriteriaField2 NVARCHAR(128) '$.CriteriaField2',
        CriteriaValue2 NVARCHAR(128) '$.CriteriaValue2',
        FromField NVARCHAR(128) '$.FromField',
        FromValue NVARCHAR(128) '$.FromValue',
        ToField NVARCHAR(128) '$.ToField',
        ToValue NVARCHAR(128) '$.ToValue',
        MappingType NVARCHAR(128) '$.MappingType',
        Required BIT '$.Required'
    )

    ---------------------------------------------------------------------------
    ----------------------------------------------- Generate the mapping SQL --
    ---------------------------------------------------------------------------

    DECLARE
        @WhenThenSeparator NVARCHAR(64) = @crlf + @tab_3,
        @CriteriaValueSeparator NVARCHAR(64) = ' OR (' + @crlf + @tab_3,
        @FromValueSeparator NVARCHAR(64) = ''',' + @crlf + @tab_4 + ''''

    SET @sqlStatement = (
        SELECT
            'UPDATE [dbo].[' + TargetTable + ']' + @crlf +
            'SET' + @crlf +
            @tab + '[' + A.ToField + '] = (' + @crlf +
            @tab_2 + 'CASE' + @crlf +
            @tab_3 + (
                SELECT
                    STRING_AGG(
                        CAST(WhenThenClauses AS NVARCHAR(max)),
                        @WhenThenSeparator
                    ) WITHIN GROUP (
                        ORDER BY
                            ToField,
                            CriteriaField1,
                            CriteriaValue1,
                            CriteriaField2,
                            CriteriaValue2,
                            FromField,
                            FromValue
                    )
                FROM
                    (
                        SELECT
                            WhenThenClauses =
                                'WHEN' + @crlf +
                                CASE
                                    WHEN
                                        ISNULL(S.CriteriaField1, '') <> '' AND ISNULL(S.CriteriaValue1, '') <> ''
                                    THEN
                                        @tab_4 + '[' + S.CriteriaField1 + '] = ''' + S.CriteriaValue1 + '''' + @crlf +
                                        @tab_4 + 'AND'
                                    ELSE ''
                                END + CASE
                                    WHEN
                                        ISNULL(S.CriteriaField2, '') <> '' AND ISNULL(S.CriteriaValue2, '') <> ''
                                    THEN
                                        IIF(
                                                ISNULL(S.CriteriaField1, '') <> '' AND ISNULL(S.CriteriaValue1, '') <> '',
                                            ' ',
                                            @tab_4
                                        ) + '[' + S.CriteriaField2 + '] = ''' + S.CriteriaValue2 + '''' + @crlf +
                                        @tab_4 + 'AND'
                                    ELSE ''
                                END +
                                    IIF(
                                            ISNULL(S.CriteriaField1, '') <> '' AND ISNULL(S.CriteriaValue1, '') <> ''
                                            OR
                                            ISNULL(S.CriteriaField2, '') <> '' AND ISNULL(S.CriteriaValue2, '') <> '',
                                        ' ',
                                        @tab_4
                                    ) +
                                    '[' + S.FromField + '] = ''' + S.FromValue + '''' + @crlf +
                                @tab_3 + 'THEN' + @crlf +
                                @tab_4 + '''' + S.ToValue + '''',
                            S.ToField,
                            S.CriteriaField1,
                            S.CriteriaValue1,
                            S.CriteriaField2,
                            S.CriteriaValue2,
                            S.FromField,
                            S.FromValue
                        FROM
                            @temp_mappings AS S
                        WHERE
                            S.PriorityOrder = A.PriorityOrder
                            AND S.MappingSetID = A.MappingSetID
                            AND S.FromField = A.FromField
                            AND S.ToField = A.ToField
                    ) T
            ) + @crlf +
            @tab_2 + 'END' + @crlf +
            @tab + ')' + @crlf +
            'WHERE' + @crlf +
            @tab + '[INTEGR_REC_BATCHREF] = ''' + CAST(@BatchRef AS NVARCHAR(128)) + '''' + @crlf +
            @tab + 'AND [INTEGR_REC_STATUS] = ''' + @IMPORTED_OK + ''' ' + @crlf +
            @tab + 'AND ISNULL([' + A.FromField + '],'''') <> '''' ' + @crlf +
            @tab + 'AND (' + @crlf +
            (
                SELECT
                    @tab_2 + '(' + @crlf +
                    @tab_3 + STRING_AGG(
                        cast(U.CriteriaValueFilter as nvarchar(max)),
                        @CriteriaValueSeparator
                    ) WITHIN GROUP (
                        ORDER BY
                            U.PriorityOrder,
                            U.MappingSetID,
                            U.CriteriaField1,
                            U.CriteriaValue1,
                            U.CriteriaField2,
                            U.CriteriaValue2,
                            U.FromField,
                            U.ToField
                    )
                FROM
                    (
                        SELECT
                            CriteriaValueFilter =
                            CASE
                                WHEN
                                    ISNULL(S.CriteriaField1, '') <> ''
                                    AND ISNULL(S.CriteriaValue1, '') <> ''
                                THEN
                                    '[' + S.CriteriaField1 + '] = ''' + S.CriteriaValue1 + '''' + @crlf +
                                    @tab_3 + 'AND '
                                ELSE ''
                            END +
                            CASE
                                WHEN
                                    ISNULL(S.CriteriaField2, '') <> ''
                                    AND ISNULL(S.CriteriaValue2, '') <> ''
                                THEN
                                    '[' + S.CriteriaField2 + '] = ''' + S.CriteriaValue2 + '''' + @crlf +
                                    @tab_3 + 'AND '
                                ELSE ''
                            END + '[' + S.FromField + '] IN (' + @crlf +
                                @tab_4 + '''' +
                                (
                                    SELECT
                                        STRING_AGG(
                                            cast(FromValue as nvarchar(max)),
                                            @FromValueSeparator
                                        ) WITHIN GROUP (
                                            ORDER BY
                                                FromValue
                                        )
                                    FROM
                                        (
                                            SELECT
                                                n.FromValue
                                            FROM
                                                @temp_mappings AS n
                                            WHERE
                                                n.PriorityOrder = S.PriorityOrder
                                                AND n.MappingSetID = S.MappingSetID
                                                AND ISNULL(n.CriteriaField1, '') = ISNULL(S.CriteriaField1, '')
                                                AND ISNULL(n.CriteriaValue1, '') = ISNULL(S.CriteriaValue1, '')
                                                AND ISNULL(n.CriteriaField2, '') = ISNULL(S.CriteriaField2, '')
                                                AND ISNULL(n.CriteriaValue2, '') = ISNULL(S.CriteriaValue2, '')
                                                AND n.FromField = S.FromField
                                                AND n.ToField = S.ToField
                                        ) T
                                ) + '''' + @crlf +
                                @tab_3 + ')' + @crlf +
                                @tab_2 + ')',
                            S.PriorityOrder,
                            S.MappingSetID,
                            S.CriteriaField1,
                            S.CriteriaValue1,
                            S.CriteriaField2,
                            S.CriteriaValue2,
                            S.FromField,
                            S.ToField
                        FROM
                            @temp_mappings AS S
                        WHERE
                            S.PriorityOrder = A.PriorityOrder
                            AND S.MappingSetID = A.MappingSetID
                            AND S.FromField = A.FromField
                            AND S.ToField = A.ToField
                        GROUP BY
                            S.PriorityOrder,
                            S.MappingSetID,
                            S.CriteriaField1,
                            S.CriteriaValue1,
                            S.CriteriaField2,
                            S.CriteriaValue2,
                            S.FromField,
                            S.ToField
                    ) U
            ) + @crlf +
            @tab + ')'
        FROM
            (
                SELECT
                    M.PriorityOrder,
                    M.MappingSetID,
                    TargetTable,
                    FromField,
                    ToField
                FROM
                    @temp_mappings AS M
                GROUP BY
                    M.PriorityOrder,
                    M.MappingSetID,
                    TargetTable,
                    FromField,
                    ToField
            ) AS A
    )

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    RETURN @sqlStatement END
