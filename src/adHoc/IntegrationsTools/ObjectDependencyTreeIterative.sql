DECLARE @RootObjectName NVARCHAR(128) = 'astp_DCS_DistributionTemplate_PopulateByDocument'

-------------------------------------------------------------------------------
------------------------------------------------------------- Working tables --
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result

CREATE TABLE #ProcessingStack
(
    StackRecordID INT IDENTITY(1, 1),
    ObjectName NVARCHAR(128),
    ParentObjectID INT,
    ObjectID INT,
    RootObjectID INT,
    Path NVARCHAR(MAX),
    Error NVARCHAR(MAX)
)
CREATE TABLE #Result
(
    ObjectName NVARCHAR(128),
    ParentObjectID INT,
    ObjectID INT,
    RootObjectID INT,
    Path NVARCHAR(MAX),
    Error NVARCHAR(MAX)
)
-------------------------------------------------------------------------------
------------------------------------------------------------ Local variables --
-------------------------------------------------------------------------------
DECLARE
    @StackRecordID INT,
    @ObjectName NVARCHAR(128),
    @ParentObjectID INT,
    @ObjectID INT,
    @RootObjectID INT,
    @Path NVARCHAR(MAX),
    @Error NVARCHAR(MAX),
    @is_incomplete BIT
-------------------------------------------------------------------------------
---------------------------------------------------------- Load initial data --
-------------------------------------------------------------------------------
INSERT INTO #ProcessingStack (
    ObjectName,
    ParentObjectID,
    ObjectID,
    RootObjectID,
    Path
)
SELECT
    ObjectName = @RootObjectName,
    ParentObjectID = NULL,
    ObjectID = object_id('dbo.' + @RootObjectName),
    RootObjectID = object_id('dbo.' + @RootObjectName),
    Path = cast('|' + cast(object_id('dbo.' + @RootObjectName) AS NVARCHAR(11)) + '|' AS NVARCHAR(MAX))
-------------------------------------------------------------------------------
--------------------------------------------------- Traverse depenency graph --
-------------------------------------------------------------------------------
WHILE(EXISTS(SELECT * FROM #ProcessingStack))
BEGIN
    /*
     * get the top of the stack
     */
    SELECT top 1
        @StackRecordID = StackRecordID,
        @ObjectName = ObjectName,
        @ParentObjectID = ParentObjectID,
        @ObjectID = ObjectID,
        @RootObjectID = RootObjectID,
        @Path = Path,
        @Error = Error
    FROM
        #ProcessingStack
    ORDER BY
        StackRecordID DESC

    /*
     * pop the stack
     */
    DELETE #ProcessingStack
    WHERE StackRecordID = @StackRecordID

    BEGIN TRY
        /*
         * Check for binding errors
         */
        SELECT @is_incomplete = max(cast(is_incomplete AS INT)) -- this is a BIT heavy but have not found another way to capture the errors
        FROM
            sys.dm_sql_referenced_entities(
                OBJECT_SCHEMA_NAME(@ObjectID) + '.' + OBJECT_NAME(@ObjectID),
                'OBJECT'
            )

        /*
         * push ON to the stack
         */
        INSERT INTO #ProcessingStack (
            ObjectName,
            ParentObjectID,
            ObjectID,
            RootObjectID,
            Path
        )
        SELECT distinct
            ObjectName = referenced_entity_name,
            ParentObjectID = @ObjectID,
            ObjectID = COALESCE(referenced_id, OBJECT_ID(referenced_entity_name)),
            RootObjectID = @RootObjectID,
            Path = @Path + cast(COALESCE(referenced_id, OBJECT_ID(referenced_entity_name)) AS NVARCHAR(11))  + '|'
        FROM
            sys.dm_sql_referenced_entities(
                OBJECT_SCHEMA_NAME(@ObjectID) + '.' + OBJECT_NAME(@ObjectID),
                'OBJECT'
            )
        WHERE
            @Path NOT LIKE '%' + cast(COALESCE(referenced_id, OBJECT_ID(referenced_entity_name)) AS NVARCHAR(11)) + '%' -- no loop !
    END TRY
    BEGIN CATCH
        -- does not seem to throw errors but sets is_incomplete column
    END CATCH

    /*
     * add to results
     */
    INSERT INTO #Result (
        ObjectName,
        ParentObjectID,
        ObjectID,
        RootObjectID,
        Path,
        Error
    )
    SELECT
        @ObjectName,
        @ParentObjectID,
        @ObjectID,
        @RootObjectID,
        @Path,
        Error =
            CASE
                WHEN @is_incomplete = 1
                THEN 'This object has one or more binding errors. The dependency trace is incomplete.'
            END
END
-------------------------------------------------------------------------------
--------------------------------------------------- Select object references --
-------------------------------------------------------------------------------
SELECT
    R.ObjectName,
    R.ParentObjectID,
    R.ObjectID,
    R.RootObjectID,
    R.Path,
    R.Error
FROM
    #Result R
ORDER BY
    R.Path
-------------------------------------------------------------------------------
