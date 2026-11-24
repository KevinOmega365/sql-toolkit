/*
 * Entra Group Users
 */
SELECT TOP 100 PERCENT
    LastName,
    FirstName,
    Email,
    AzureId
FROM
    dbo.atbl_TGE_AzureAdUsers_Staging
ORDER BY
    LastName,
    FirstName

/*
 * Linked Users
 */
SELECT TOP 100 PERCENT
    S.LastName,
    S.FirstName,
    S.Email,
    S.AzureId
FROM
    dbo.atbl_TGE_AzureAdUsers_Staging AS S
    JOIN dbo.stbl_System_Persons AS P ON P.ADAccount = CAST(S.AzureId AS CHAR(36))

/*
 * Potential Links
 */
SELECT TOP 100 PERCENT
    S.LastName,
    S.FirstName,
    S.Email,
    S.AzureId
FROM
    dbo.atbl_TGE_AzureAdUsers_Staging AS S
    JOIN dbo.stbl_System_PersonsUsers AS U ON U.External_ID = CAST(S.AzureId AS CHAR(36))
    JOIN dbo.stbl_System_Persons AS P ON P.ID = U.Person_ID
WHERE
    P.ADAccount IS NULL

/*
 * Outliers
 */
SELECT TOP 100 PERCENT
    S.LastName,
    S.FirstName,
    S.Email,
    S.AzureId
FROM
    dbo.atbl_TGE_AzureAdUsers_Staging AS S
    JOIN dbo.stbl_System_Persons AS P ON P.Email = S.Email
    LEFT JOIN dbo.stbl_System_PersonsUsers AS U ON U.External_ID = CAST(S.AzureId AS CHAR(36))
WHERE
    U.ID IS NULL
    AND P.ADAccount IS NULL