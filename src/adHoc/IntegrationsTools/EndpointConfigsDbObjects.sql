-------------------------------------------------------------------------------
declare @databaseObjectPattern nvarchar(max) = '[al][stv][bit][lpvwx][_]%' --  astp|atbl|atbx|atbv|aviw|lstp|ltbl|ltbx|ltbv|lviw
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack (
    EndPointRef uniqueidentifier,
    StackRecordID INT IDENTITY(1, 1),
    JsonObject nvarchar(max),
    Type int,
    JsonPath nvarchar(max)
)
CREATE TABLE #Result (
    EndPointRef uniqueidentifier,
    JsonPath nvarchar(max),
    StringValue nvarchar(max),
    Type int
)
-------------------------------------------------------------------------------
/*
 * Add the initial population
 */
insert into #ProcessingStack (
    EndPointRef,
    JsonObject,
    JsonPath,
    Type
)
select
    EndPointRef = PrimKey,
    JsonObject = EndpointConfig,
    JsonPath = '$',
    Type = 5 -- assume that the top level JSON is an object (not array)
from
    dbo.atbl_Integrations_Setup_Endpoints with (nolock)
where
    isjson(EndpointConfig) = 1
-------------------------------------------------------------------------------
declare
    @EndPointRef uniqueidentifier,
    @StackRecordID int,
    @JsonObject nvarchar(max),
    @Type int,
    @JsonPath nvarchar(max)
-------------------------------------------------------------------------------
while(exists (select * from #ProcessingStack))
begin
    /*
     *  get the top the stack
     */
    select top 1
        @EndPointRef = EndPointRef,
        @StackRecordID = StackRecordID,
        @JsonObject = JsonObject,
        @Type = Type,
        @JsonPath = JsonPath
    from
        #ProcessingStack
    order by
        StackRecordID desc

    /*
     * pop the stack
     */
    delete #ProcessingStack
    where StackRecordID = @StackRecordID

    /*
    * Put basic values in the result
    */
    insert into #Result (
        EndPointRef,
        JsonPath,
        StringValue,
        Type
    )
    select
        @EndPointRef,
        JsonPath =
            @JsonPath +
            case when @Type = 4 then '[' else '.' end +
            Entries.[key] +
            case when @Type = 4 then ']' else '' end
        ,
        Entries.value,
        Entries.type
    from
        openjson(@JsonObject) Entries
    where
        Entries.type in (0, 1, 2, 3)

/*
* Put structure(s) back on the stack
*/
insert into #ProcessingStack (
    EndPointRef,
    JsonObject,
    JsonPath,
    Type
)
    select
        @EndPointRef,
        Entries.value,
        EntryPath =
            @JsonPath +
            case when @Type = 4 then '[' else '.' end +
            Entries.[key] +
            case when @Type = 4 then ']' else '' end
        ,
        Entries.type
    from
        openjson(@JsonObject) Entries
    where
        Entries.type in (4, 5)
end
-------------------------------------------------------------------------------
select
    Endpoints.System,
    Endpoints.Name,
    Results.EndPointRef,
    Results.JsonPath,
    Results.StringValue,
    Results.Type,
    ValueFromPath = json_value(Endpoints.EndpointConfig, JsonPath COLLATE Latin1_General_CI_AS)
from
    #Result Results
    join dbo.atbl_Integrations_Setup_Endpoints Endpoints with (nolock)
        on EndPoints.PrimKey = Results.EndPointRef
where
    StringValue like @databaseObjectPattern

select * from #ProcessingStack order by StackRecordID desc