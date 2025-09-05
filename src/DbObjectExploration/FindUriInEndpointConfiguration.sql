-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack (
    RootId uniqueidentifier,
    StackRecordID INT IDENTITY(1, 1),
    JsonObject nvarchar(max),
    Type int,
    JsonPath nvarchar(max)
)
CREATE TABLE #Result (
    RootId uniqueidentifier,
    JsonPath nvarchar(max),
    StringValue nvarchar(max),
    Type int
)
-------------------------------------------------------------------------------
/*
 * Add the initial population
 */
insert into #ProcessingStack (
    RootId,
    JsonObject,
    JsonPath,
    Type
)
select -- top 3
    RootId = PrimKey,
    JsonObject = EndpointConfig,
    JsonPath = '$',
    Type = 5 -- assume that the top level JSON is an object (not array)
from
    dbo.atbl_Integrations_Setup_Endpoints with (nolock)
-- order by
--     newid()
-------------------------------------------------------------------------------
declare
    @RootId uniqueidentifier,
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
        @RootId = RootId,
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
        RootId,
        JsonPath,
        StringValue,
        Type
    )
    select
        RootId = @RootId,
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
    RootId,
    JsonObject,
    JsonPath,
    Type
)
    select
        @RootId,
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
    E.System,
    E.Name,
    R.JsonPath,
    R.StringValue,
    R.Type,
    PathValue = json_value(E.EndpointConfig, JsonPath COLLATE Latin1_General_CI_AS)
from
    #Result R
    join dbo.atbl_Integrations_Setup_Endpoints E with (nolock)
        on E.PrimKey = RootId
where
    StringValue like 'http%://%'
order by
    E.System,
    E.Name,
    R.JsonPath


-- select * from #ProcessingStack order by StackRecordID desc -- debug
