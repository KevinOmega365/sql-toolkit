
SELECT TOP 100 PERCENT P.PrimKey
-- -- UPDATE P SET
-- --     P.ADAccount = CAST(S.AzureId AS CHAR(36))
FROM
    dbo.atbl_TGE_AzureAdUsers_Staging AS S
    JOIN dbo.stbl_System_PersonsUsers AS U ON U.External_ID = CAST(S.AzureId AS CHAR(36))
    JOIN dbo.stbl_System_Persons AS P ON P.ID = U.Person_ID
WHERE
    P.ADAccount IS NULL

-- select count(distinct Email) from
-- (SELECT TOP 100 PERCENT
--     S.LastName,
--     S.FirstName,
--     S.Email,
--     S.AzureId
-- FROM
--     dbo.atbl_TGE_AzureAdUsers_Staging AS S
--     JOIN dbo.stbl_System_PersonsUsers AS U ON U.External_ID = CAST(S.AzureId AS CHAR(36))
--     JOIN dbo.stbl_System_Persons AS P ON P.ID = U.Person_ID
-- WHERE
--     P.ADAccount IS NULL) t

-- SELECT TOP 100 PERCENT
--     S.LastName,
--     S.FirstName,
--     S.Email,
--     S.AzureId
-- FROM
--     dbo.atbl_TGE_AzureAdUsers_Staging AS S
--     JOIN dbo.stbl_System_PersonsUsers AS U ON U.External_ID = CAST(S.AzureId AS CHAR(36))
--     JOIN dbo.stbl_System_Persons AS P ON P.ID = U.Person_ID
-- WHERE
--     P.ADAccount IS NULL
