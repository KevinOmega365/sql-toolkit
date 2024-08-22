SELECT top 50
    PrimKey,
    Created,
    CreatedBy,
    Updated,
    UpdatedBy,
    ServiceName,
    ExecutionGroupRef,
    ExecutionBatchRef,
    ExecutionTaskRef,
    CallingObject,
    CallingMethod,
    CallingParameters,
    Message,
    JsonExtract = reverse(left(reverse(left(Message, charindex('}', Message))), charindex('{', reverse(left(Message, charindex('}', Message)))))),
    JsonCheck = isjson(reverse(left(reverse(left(Message, charindex('}', Message))), charindex('{', reverse(left(Message, charindex('}', Message))))))),
    StackTrace,
    LogLevel,
    SortOrder
FROM
    dbo.aviw_Integrations_ScheduledTasksServicesLog
WHERE
    ExecutionGroupRef = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
    and Message like '%404%'
ORDER BY
    Created DESC