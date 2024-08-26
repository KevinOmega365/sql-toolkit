DECLARE
    @AssemblyObject nvarchar(128) = 'Integrations.Interface.RestAPI.FileHandlers.DtsFileHandler',
    @Pipeline nvarchar(38) = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @StartDate date = '2024-08-25'

SELECT
    [PrimKey],
    [Created],
    [CreatedBy],
    [Updated],
    [UpdatedBy],
    [ServiceName],
    [ExecutionGroupRef],
    [ExecutionBatchRef],
    [ExecutionTaskRef],
    [CallingObject],
    [CallingMethod],
    [CallingParameters],
    [Message],
    [StackTrace],
    [LogLevel],
    [SortOrder]
FROM
    (
        SELECT
            T.PrimKey,
            T.Created,
            T.CreatedBy,
            T.Updated,
            T.UpdatedBy,
            T.ServiceName,
            T.ExecutionGroupRef,
            T.ExecutionBatchRef,
            T.ExecutionTaskRef,
            T.CallingObject,
            T.CallingMethod,
            T.CallingParameters,
            T.Message,
            T.StackTrace,
            T.LogLevel,
            RANK() OVER (
                ORDER BY
                    CAST(created AS datetimeoffset) DESC
            ) AS SortOrder
        FROM
            dbo.atbl_Integrations_ScheduledTasksServicesLog AS T WITH (NOLOCK)
    ) T
WHERE
    (
        [CallingObject] = @AssemblyObject
        AND [ExecutionGroupRef] LIKE @Pipeline
        AND [Created] >= @StartDate
    )