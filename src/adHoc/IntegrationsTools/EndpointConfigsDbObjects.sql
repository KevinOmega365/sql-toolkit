    ---------------------------------------------------------------------------
    DECLARE @databaseObjectPattern NVARCHAR(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw
    ---------------------------------------------------------------------------
    -- ref:https://learn.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql?view=sql-server-ver16
    DECLARE
        @Null TINYINT = 0,
        @String TINYINT = 1,
        @Number TINYINT = 2,
        @TrueFalse TINYINT = 3,
        @Array TINYINT = 4,
        @Object TINYINT = 5
    ---------------------------------------------------------------------------
    DROP TABLE IF EXISTS #ProcessingStack
    DROP TABLE IF EXISTS #Result
    ---------------------------------------------------------------------------
    CREATE TABLE #ProcessingStack (
        EndPointRef uniqueidentifier,
        StackRecordID INT IDENTITY(1, 1),
        JsonObject NVARCHAR(max),
        TYPE INT,
        JsonPath NVARCHAR(max)
    )
    CREATE TABLE #Result (
        EndPointRef uniqueidentifier,
        JsonPath NVARCHAR(max),
        StringValue NVARCHAR(max),
        TYPE INT
    )
    ---------------------------------------------------------------------------
    /*
     * Add the initial population
     */
    INSERT INTO
        #ProcessingStack (
            EndPointRef,
            JsonObject,
            JsonPath,
            TYPE
        )
    SELECT
        EndPointRef = PrimKey,
        JsonObject = EndpointConfig,
        JsonPath = '$',
    TYPE = @Object -- assume that the top level JSON is an object (not array)
    FROM
        dbo.atbl_Integrations_Setup_Endpoints WITH (NOLOCK)
    WHERE
        ISJSON(EndpointConfig) = 1
    ---------------------------------------------------------------------------
    DECLARE
        @EndPointRef uniqueidentifier,
        @StackRecordID INT,
        @JsonObject NVARCHAR(max),
        @Type INT,
        @JsonPath NVARCHAR(max)
    ---------------------------------------------------------------------------
    WHILE (
        EXISTS (
            SELECT
                *
            FROM
                #ProcessingStack
        )
    )
    BEGIN
    /*
     *  get the top the stack
     */
    SELECT
        TOP 1 @EndPointRef = EndPointRef,
        @StackRecordID = StackRecordID,
        @JsonObject = JsonObject,
        @Type = TYPE,
        @JsonPath = JsonPath
    FROM
        #ProcessingStack
    ORDER BY
        StackRecordID DESC
    /*
     * pop the stack
     */
    DELETE #ProcessingStack
    WHERE
        StackRecordID = @StackRecordID
    /*
     * Put basic values in the result
     */
    INSERT INTO
        #Result (
            EndPointRef,
            JsonPath,
            StringValue,
            TYPE
        )
    SELECT
        @EndPointRef,
        JsonPath = @JsonPath + CASE
            WHEN @Type = @Array THEN '['
            ELSE '.'
        END + Entries.[key] + CASE
            WHEN @Type = @Array THEN ']'
            ELSE ''
        END,
        Entries.value,
        Entries.type
    FROM
        openjson (@JsonObject) Entries
    WHERE
        Entries.type IN (@Null, @String, @Number, @TrueFalse)
    /*
     * Put structure(s) back on the stack
     */
    INSERT INTO
        #ProcessingStack (
            EndPointRef,
            JsonObject,
            JsonPath,
            TYPE
        )
    SELECT
        @EndPointRef,
        Entries.value,
        EntryPath = @JsonPath + CASE
            WHEN @Type = @Array THEN '['
            ELSE '.'
        END + Entries.[key] + CASE
            WHEN @Type = @Array THEN ']'
            ELSE ''
        END,
        Entries.type
    FROM
        openjson (@JsonObject) Entries
    WHERE
        Entries.type IN (@Array, @Object) END
    ---------------------------------------------------------------------------
    -- INSERT INTO dbo.atbl_Integrations_DevTools_DatabaseObjectSources
    -- (
    --     SourceType,
    --     SourceParentRef,
    --     SourceRef,
    --     ObjectName
    -- )
    SELECT
        Endpoints.System,
        Endpoints.Name,
        Results.EndPointRef,
        Results.JsonPath,
        Results.StringValue,
        Results.Type,
        ValueFromPath = JSON_VALUE(
            Endpoints.EndpointConfig,
            JsonPath
            COLLATE Latin1_General_CI_AS
        )
    FROM
        #Result Results
        JOIN dbo.atbl_Integrations_Setup_Endpoints Endpoints WITH (NOLOCK)
            ON EndPoints.PrimKey = Results.EndPointRef
    WHERE
        StringValue LIKE @databaseObjectPattern
    ---------------------------------------------------------------------------
