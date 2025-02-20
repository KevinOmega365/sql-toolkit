-------------------------------------------------------------------------------
declare @SampleJsonObject nvarchar(max) = '{
    "foo": "bar",
    "baz": "qux",
    "wat": [
        "bleep",
        "blorp",
        1337,
        { "key": "really", "really": false }
    ]
}'
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack (
    StackRecordID INT IDENTITY(1, 1),
    JsonObject nvarchar(max),
    Type int,
    JsonPath nvarchar(max)
)
CREATE TABLE #Result (
    JsonPath nvarchar(max),
    StringValue nvarchar(max),
    Type int
)
-------------------------------------------------------------------------------
/*
 * Add the initial population
 */
insert into #ProcessingStack (
    JsonObject,
    JsonPath,
    Type
)
values
    (@SampleJsonObject, '$', 5) -- assume that the top level JSON is an object (not array)
-------------------------------------------------------------------------------
declare
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
        JsonPath,
        StringValue,
        Type
    )
    select
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
    JsonObject,
    JsonPath,
    Type
)
    select
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
    JsonPath,
    StringValue,
    Type,
    PathValue = json_value(@SampleJsonObject, JsonPath)
from
    #Result


select * from #ProcessingStack order by StackRecordID desc