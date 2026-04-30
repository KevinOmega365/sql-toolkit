-- JSON to Markdown
-- root -> list header -> list entries
-- object > array+ > string+
-------------------------------------------------------------------------------
declare @RootKeyTitle nvarchar(128) = 'Trace'
declare @SampleJsonObject nvarchar(max) = '{
    "action": [],
    "scope": [
        "DocumentNumber is blacklisted",
        "Documents can not start with anything else then PWP, FEN or VAL"
    ],
    "transform": [
        "AkerBP Distribution set to for information"
    ],
    "validation": [
        "The PO Number (BC507) is not configured in Pims for the Contract No (C-01989)"
    ],
    "warning": [],
    "error": [
        "Multiple scope messages"
    ]
}'
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack (
    StackRecordID INT IDENTITY(1, 1),
    EntryKey nvarchar(max),
    JsonObject nvarchar(max),
    Type int,
    JsonPath nvarchar(max),
    Depth int
)
CREATE TABLE #Result (
    JsonPath nvarchar(max),
    EntryKey nvarchar(max),
    StringValue nvarchar(max),
    Type int,
    Depth int
)
-------------------------------------------------------------------------------
/*
 * Add the initial population
 */
insert into #ProcessingStack (
    JsonObject,
    EntryKey,
    JsonPath,
    Type,
    Depth
)
values
    (@SampleJsonObject, @RootKeyTitle, '$', 5, 0) -- assume that the top level JSON is an object (not array)
-------------------------------------------------------------------------------
declare
    @StackRecordID int,
    @JsonObject nvarchar(max),
    @EntryKey nvarchar(max),
    @Type int,
    @JsonPath nvarchar(max),
    @Depth int
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
        @EntryKey = EntryKey,
        @JsonPath = JsonPath,
        @Depth = Depth
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
     * Put the parent into the result (for headings)
     */
    insert into #Result (
        JsonPath,
        EntryKey,
        StringValue ,
        Type,
        Depth
    )
    values (
        @JsonPath,
        @EntryKey,
        null, -- StringValue
        @Type,
        @Depth
    )


    /*
     * Put basic values in the result
     */
    insert into #Result (
        JsonPath,
        StringValue,
        Type,
        Depth
    )
    select
        JsonPath =
            @JsonPath +
            case when @Type = 4 then '[' else '.' end +
            Entries.[key] +
            case when @Type = 4 then ']' else '' end
        ,
        Entries.value,
        Entries.type,
        Depth = @Depth + 1
    from
        openjson(@JsonObject) Entries
    where
        Entries.type in (0, 1, 2, 3)

    /*
     * Put structure(s) back on the stack
     */
    insert into #ProcessingStack (
        JsonObject,
        EntryKey,
        JsonPath,
        Type,
        Depth
    )
    select
        Entries.value,
        Entries.[key],
        EntryPath =
            @JsonPath +
            case when @Type = 4 then '[' else '.' end +
            Entries.[key] +
            case when @Type = 4 then ']' else '' end
        ,
        Entries.type,
        Depth = @Depth + 1
    from
        openjson(@JsonObject) Entries
    where
        Entries.type in (4, 5)
end

-------------------------------------------------------------------------------

declare @crlf char(2) = CHAR(13)+CHAR(10)
select
    Markdown =
        string_agg(
            case
                when Type in (4, 5)
                then IIF(depth = 1, @crlf, '') + replicate('#', depth + 1) + ' ' + isnull(EntryKey, 'NOPE!') + IIF(depth = 1, @crlf, '')
                else '* ' + isnull(StringValue, 'NOPE!')
            end
            , @crlf
        )
        + @crlf
from
    (
        select
            Depth,
            EntryKey,
            JsonPath,
            StringValue,
            Type,
            PathValue = case 
                when type in (4, 5)
                then json_query(@SampleJsonObject, JsonPath)
                else json_value(@SampleJsonObject, JsonPath)
            end,
            IsEmpty = case
                when Type in (4, 5)
                then iif((select count(*) from openjson(json_query(@SampleJsonObject, JsonPath))) = 0, 1, 0)
                else 0
            end
        from
            #Result
    ) T
where
    IsEmpty = 0


select
    Depth,
    EntryKey,
    JsonPath,
    StringValue,
    Type,
    PathValue = case 
        when type in (4, 5)
        then json_query(@SampleJsonObject, JsonPath)
        else json_value(@SampleJsonObject, JsonPath)
    end,
    IsEmpty = case
        when Type in (4, 5) then iif((select count(*) from openjson(json_query(@SampleJsonObject, JsonPath))) = 0, 1, 0)
        else 0
    end
from
    #Result

select * from #ProcessingStack order by StackRecordID desc
