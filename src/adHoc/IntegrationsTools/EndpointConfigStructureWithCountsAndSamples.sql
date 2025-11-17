
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #ProcessingStack
DROP TABLE IF EXISTS #Result
DROP TABLE IF EXISTS #JsonTypes
-------------------------------------------------------------------------------
CREATE TABLE #ProcessingStack (
    StackRecordID INT IDENTITY(1, 1),
    ConfigRef uniqueidentifier,
    StepType nvarchar(50),
    JsonObject nvarchar(max),
    Type int,
    JsonPath nvarchar(max)
)
CREATE TABLE #Result (
    ConfigRef uniqueidentifier,
    StepType nvarchar(50),
    JsonPath nvarchar(max),
    StringValue nvarchar(max),
    Type int
)
CREATE TABLE #JsonTypes (
    TypeName nvarchar(128),
    TypeKey int
)
INSERT INTO #JsonTypes
VALUES
    ('String', 1),
    ('DoublePrecisionFloatingPoint', 2),
    ('Boolean', 3),
    ('Null', 0),
    ('Array', 4),
    ('Object', 5)

-------------------------------------------------------------------------------
/*
 * Add the initial population
 *
 * NB: 
 */
INSERT INTO #ProcessingStack (
    ConfigRef,
    StepType,
    JsonObject,
    JsonPath,
    Type
)
SELECT DISTINCT
    E.PrimKey,
    S.StepType,
    E.EndpointConfig,
    '$',
    5 -- assume that the top level JSON is an object (not array)
FROM
    dbo.atbl_Integrations_Setup_Endpoints AS E WITH (NOLOCK)
    INNER JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS S WITH (NOLOCK)
        ON ISJSON(S.StepConfig) = 1
        AND JSON_VALUE(S.StepConfig, '$.QuerySystem') = E.[System]
        AND JSON_VALUE(S.StepConfig, '$.QueryName') = E.[Name]

-------------------------------------------------------------------------------

declare
    @StepType nvarchar(50),
    @ConfigRef uniqueidentifier,
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
            @ConfigRef = ConfigRef,
            @StepType = StepType,
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
            ConfigRef,
            StepType,
            JsonPath,
            StringValue,
            Type
        )
        select
            ConfigRef = @ConfigRef,
            StepType = @StepType,
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
        ConfigRef,
        StepType,
        JsonObject,
        JsonPath,
        Type
    )
        select
            ConfigRef = @ConfigRef,
            StepType = @StepType,
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
    T.StepType,
    T.JsonPath,
    IstanceCount =
        cast(count(*) as nvarchar(max)) +
        ' / ' +
        cast((
            select count(distinct S.ConfigRef)
            from #Result S
            where
                S.StepType = T.StepType
        ) as nvarchar(max)),
    SampleValues = case
        when Type = 1 then
            '["' +
            (
                select string_agg(StringValue, '", "')
                from
                (
                    select top 5 StringValue
                    from #Result S
                    where
                        S.StepType = T.StepType
                        and S.JsonPath = T.JsonPath
                    group by
                        StringValue
                    order by
                        newid() -- random sample
                ) U
            ) +
            '"]'
        else
            '[' +
            (
                select string_agg(StringValue, ', ')
                from
                (
                    select top 5 StringValue
                    from #Result S
                    where
                        S.StepType = T.StepType
                        and S.JsonPath = T.JsonPath
                    group by
                        StringValue
                    order by
                        newid() -- random sample
                ) U
            ) +
            ']'
        end,
    Type = (select TypeName from #JsonTypes JT where JT.TypeKey = T.Type)
from
(
    select
        R.StepType,
        R.JsonPath,
        R.StringValue,
        R.Type,
        PathValue = json_value(E.EndpointConfig, R.JsonPath collate SQL_Latin1_General_CP1_CI_AS)
    from
        #Result R
        join dbo.atbl_Integrations_Setup_Endpoints AS E WITH (NOLOCK)
            on E.PrimKey = R.ConfigRef
) T
group by
    T.StepType,
    T.JsonPath,
    T.Type
order by
    T.StepType,
    T.JsonPath,
    T.Type


-- debug
select *
from #ProcessingStack
order by StackRecordID desc
