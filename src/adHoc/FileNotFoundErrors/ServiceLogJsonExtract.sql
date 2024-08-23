/*

Questions:

How often?
How much?
How many recurences?

Which 404 error don't have JSON content

How do these corellate with import messages

*/

select
    LogEntries.Created,
    LogEntries.ExecutionGroupRef,
    LogEntries.ExecutionBatchRef,
    -- MessageJsonContent.md5hash,
    MessageJsonContent.object_guid,
    MessageJsonContent.originalFilename,
    MessageJsonContent.ShortMessage
    -- LogEntries.Message,
    -- LogEntries.JsonExtract,
    -- LogEntries.JsonCheck = isjson(JsonExtract)
from
    (
        SELECT TOP 50
            Created,
            ExecutionGroupRef,
            ExecutionBatchRef,
            ShortMessage = right(Message, len(Message) - charindex('}', Message) - 3),
            Message,
            JsonExtract =
                reverse(
                    left(
                        reverse(
                            left(
                                Message,
                                charindex('}', Message)
                            )
                        ),
                        charindex(
                            '{',
                            reverse(left(Message, charindex('}', Message)))
                        )
                    )
                )
        FROM
            dbo.atbl_Integrations_ScheduledTasksServicesLog AS LogEntries WITH(NOLOCK)
        WHERE
            ExecutionGroupRef = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
            and Message like '%404%'
    ) LogEntries
    cross apply openjson(JsonExtract)
        with (
            md5hash nvarchar(max),
            object_guid nvarchar(max),
            originalFilename nvarchar(max)
        ) MessageJsonContent
ORDER BY
    Created DESC
