declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare
    @AssemblyObject nvarchar(128) = 'Integrations.Interface.RestAPI.FileHandlers.DtsFileHandler',
    @Pipeline nvarchar(38) = @Munin,
    @StartDate date = '2024-08-25'

/*
    Questions:

        How often?
        How much?
        How many recurences?

        Which 404 error don't have JSON content!?!

        How do these corellate with import messages?
*/

select
    LogEntries.Created,
    LogEntries.ExecutionGroupRef,
    LogEntries.ExecutionBatchRef,
    -- MessageJsonContent.md5hash,
    MessageJsonContent.object_guid,
    MessageJsonContent.originalFilename,
    -- MessageJsonContent.ShortMessage
    LogEntries.Message
    -- LogEntries.JsonExtract,
    -- LogEntries.JsonCheck = isjson(JsonExtract)
from
    (
        SELECT TOP 50
            Created,
            ExecutionGroupRef,
            ExecutionBatchRef,
            -- ShortMessage = right(Message, len(Message) - charindex('}', Message) - 3),
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
            ExecutionGroupRef = @Pipeline
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
