
DECLARE @TestingPipelinePrimKey UNIQUEIDENTIFIER = '98b779b1-02ef-4886-82ef-19ab350f4ab3'

/*
 * Proc parameters
 */
DECLARE @PipelineStepPrimKey UNIQUEIDENTIFIER = '9fce2e18-b4e9-4f1e-b849-257a560f1763' 
DECLARE @newSequenceOrder NVARCHAR(15) = '1.1.1'

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @MockGroupTasks table
(
    PrimKey uniqueidentifier,
    GroupRef uniqueidentifier,
    SortOrder int,
    SequenceOrder nvarchar(15)
)

insert into @MockGroupTasks
(
    PrimKey,
    GroupRef,
    SortOrder,
    SequenceOrder
)
select top 50
    PrimKey,
    GroupRef,
    SortOrder,
    SequenceOrder
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks with (nolock)
where
    GroupRef=@TestingPipelinePrimKey
order by
    SortOrder

select * 
into #OriginalMockGroupTasks
from @MockGroupTasks
order by SortOrder

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

    DECLARE @newSortOrder INT = 0
    DECLARE @newSequenceOrderPrefix NVARCHAR(15)
    DECLARE @newSequenceOrderLastPart NVARCHAR(15)

    DECLARE @GroupRef AS UNIQUEIDENTIFIER;

    SELECT @GroupRef=GroupRef FROM @MockGroupTasks WHERE PrimKey = @PipelineStepPrimKey;

    IF EXISTS (
        SELECT TOP 1 1 
        FROM @MockGroupTasks
        WHERE GroupRef = @GroupRef AND PrimKey <> @PipelineStepPrimKey AND SequenceOrder = @newSequenceOrder
    )
    BEGIN
        DECLARE @NumDots INT = 0
        SET @NumDots = LEN(@newSequenceOrder) - LEN(REPLACE(@newSequenceOrder, '.', ''))

        SELECT @newSortOrder =  dbo.afnc_Integrations_GetSortOrder(@newSequenceOrder)

        SET @newSequenceOrderPrefix = LEFT(@newSequenceOrder,LEN(@newSequenceOrder) - CHARINDEX('.', REVERSE(@newSequenceOrder))+1)
        SET @newSequenceOrderLastPart = SUBSTRING(@newSequenceOrder, LEN(@newSequenceOrderPrefix)+1, LEN(@newSequenceOrder) - LEN(@newSequenceOrderPrefix)+1)

        IF @NumDots = 0
        BEGIN
            print 'no dots for you'
            UPDATE @MockGroupTasks 
            SET SequenceOrder = '999', SortOrder = dbo.afnc_Integrations_GetSortOrder('999')
            FROM @MockGroupTasks
            WHERE GroupRef = @GroupRef AND PrimKey = @PipelineStepPrimKey;

            UPDATE @MockGroupTasks 
            SET SequenceOrder = SequenceOrder + 1, SortOrder = dbo.afnc_Integrations_GetSortOrder(SequenceOrder + 1)
            FROM @MockGroupTasks
            WHERE GroupRef = @GroupRef AND PrimKey <> @PipelineStepPrimKey AND SortOrder >= @newSortOrder
        END

        IF @NumDots > 0
        BEGIN
            print 'throw more dots'
            UPDATE @MockGroupTasks 
            SET SequenceOrder = '999'
            FROM @MockGroupTasks
            WHERE GroupRef = @GroupRef AND PrimKey = @PipelineStepPrimKey;

            UPDATE @MockGroupTasks 
            SET
                SequenceOrder = @newSequenceOrderPrefix + CAST(CAST(SUBSTRING(SequenceOrder, LEN(@newSequenceOrderPrefix)+1, LEN(SequenceOrder) - LEN(@newSequenceOrderPrefix)+1) AS INT) + 1 AS NVARCHAR(MAX)),
                SortOrder = dbo.afnc_Integrations_GetSortOrder(@newSequenceOrderPrefix + CAST(CAST(SUBSTRING(SequenceOrder, LEN(@newSequenceOrderPrefix)+1, LEN(SequenceOrder) - LEN(@newSequenceOrderPrefix)+1) AS INT) + 1 AS NVARCHAR(MAX)))
            FROM @MockGroupTasks
            WHERE GroupRef = @GroupRef AND PrimKey <> @PipelineStepPrimKey AND SortOrder >= @newSortOrder AND SequenceOrder LIKE @newSequenceOrderPrefix + '%';
        END
    END

    UPDATE @MockGroupTasks
    SET SequenceOrder = @newSequenceOrder, SortOrder = dbo.afnc_Integrations_GetSortOrder(@newSequenceOrder)
    FROM @MockGroupTasks
    WHERE GroupRef = @GroupRef AND PrimKey = @PipelineStepPrimKey;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

select * from @MockGroupTasks order by SortOrder
select * from #OriginalMockGroupTasks order by SortOrder
