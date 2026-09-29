-- UPDATE U SET
SELECT TOP 100
    ADLogin = AzureID,
    OpenIDLogin = Email
FROM
    dbo.atbl_AzureAdSync_Users AS I WITH (NOLOCK)
    join dbo.stbl_System_Users as U with (nolock)
        on U.Login = I.Email