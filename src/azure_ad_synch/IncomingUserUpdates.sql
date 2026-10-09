/*
 * In-coming updates
 */

-------------------------------------------------------------------------------

declare @lastRunStart int

-------------------------------------------------------------------------------

select top 1
    @lastRunStart = min(AutoID) - 1 -- the start message doesn't have the run id ><. doh!
from
    dbo.atbl_AzureAdSync_Log with (nolock)
where
    json_value(LogMessage, '$.runId') is not null
group by
    json_value(LogMessage, '$.runId')
order by
    min(AutoID) desc

-------------------------------------------------------------------------------

select
    FirstNameChange = cast(case when U.FirstName <> UserUpdates.GivenName then 1 else 0 end as bit),
    LastNameChange = cast(case when U.LastName <> UserUpdates.Surname then 1 else 0 end as bit),
    EmailChange = cast(case when U.UserEmail <> UserUpdates.Email then 1 else 0 end as bit),
    UserUpdates.AzureID,
    UserUpdates.Login,
    UserUpdates.DisplayName,
    UserUpdates.GivenName,
    UserUpdates.Surname,
    U.FirstName,
    U.LastName,
    UserUpdates.Email,
    U.UserEmail
from
    dbo.atbl_AzureAdSync_Log with (nolock)
    cross apply openjson(LogMessage, '$.dataset')
        with (
            AzureID nvarchar(128),
            Login nvarchar(128),
            DisplayName nvarchar(128),
            GivenName nvarchar(128),
            Surname nvarchar(128),
            Email nvarchar(128)
        ) UserUpdates
    join dbo.stbl_System_Users U with (nolock)
        on U.Login = UserUpdates.Login
where
    AutoID >= @lastRunStart
    and json_value(LogMessage, '$.type') = 'UPDATE_USER_INFO'

-------------------------------------------------------------------------------
