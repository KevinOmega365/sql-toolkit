
    DECLARE @RunID UNIQUEIDENTIFIER = NEWID()

    ------------------------------------- Get new persons from azure [START] --
    DROP TABLE IF EXISTS #NewUsers;
    
    CREATE TABLE #NewUsers (
        ADAccount NVARCHAR(50),
        Email NVARCHAR(200),
        FirstName NVARCHAR(100),
        LastName NVARCHAR(100),
        Comment NVARCHAR(1000),
        OrgUnit_ID INT,
        DTJson NVARCHAR(max)
    )

    /*
     * Collect list
     */
    INSERT INTO #NewUsers (
        ADAccount,
        Email,
        FirstName,
        LastName,
        Comment,
        OrgUnit_ID,
        DTJson
    )
    SELECT
        s.AzureID,
        s.Email,
        s.FirstName,
        s.LastName,
        'Imported FROM Azure AD:' + cast(getdate() AS VARCHAR(50)) AS Comment,
        ou.OrgUnit_ID,
        (
            SELECT s2.*
            FROM dbo.atbl_Tge_AzureAdUsers_Staging AS s2
            WHERE s.ID = s2.ID
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        ) AS DTJson
    FROM
        dbo.atbl_Tge_AzureAdUsers_Staging s
        JOIN dbo.atbl_TGE_AzureAdGroupsOrgUnits ou
            ON s.Email like '%@' + ou.EmailDomain -- org unit is based user email domain
    WHERE
        s.Email IS NOT NULL
        AND FirstName IS NOT NULL
        AND LastName  IS NOT NULL
        AND s.AzureID IS NOT NULL
        AND NOT EXISTS (
            SELECT
                ADAccount
            FROM
                dbo.stbl_System_Persons p2
            WHERE
                CAST(s.AzureID AS NVARCHAR(50)) = p2.ADAccount
        )
    --------------------------------------- Get new persons from azure [END] --

    --------------------------------------------- Log Excluded Users [Start] --
    DROP TABLE IF EXISTS #ExcludedUsersLogMessages;
    CREATE TABLE #ExcludedUsersLogMessages (LogMessage NVARCHAR(MAX))

    /*
     * Collect list
     */
    INSERT INTO #ExcludedUsersLogMessages (LogMessage)
    SELECT
        LogMessage = (
            SELECT
                RunID = @RunID,
                TYPE = 'WARNING',
                Message = 'Unable to add user',
                StageData = JSON_QUERY(
                    (
                        SELECT s2.*
                        FROM dbo.atbl_Tge_AzureAdUsers_Staging AS s2
                        WHERE s.ID = s2.ID
                        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                    ),
                    '$'
                )
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    FROM
        dbo.atbl_Tge_AzureAdUsers_Staging s
        LEFT JOIN #NewUsers n
            ON n.ADAccount = s.AzureID
    WHERE
        n.DTJson IS NULL
        AND NOT EXISTS (
            SELECT
                ADAccount
            FROM
                dbo.stbl_System_Persons p2
            WHERE
                CAST(s.AzureID AS NVARCHAR(50)) = p2.ADAccount
        )

    ----------------------------------------------- Log Excluded Users [End] --

    --------------------------------------------------- Expire users [START] --
    DROP TABLE IF EXISTS #UsersToExpire;
    CREATE TABLE #UsersToExpire (ID INT)

    /*
     * Collect list
     */
    INSERT INTO
        #UsersToExpire (ID)
    SELECT DISTINCT
        ID
    FROM
        (
            SELECT
                P.ID,
                P.ADAccount,
                P.Email,
                P.FirstName,
                P.LastName,
                P.Comment,
                P.DTJson
            FROM
                dbo.stbl_System_Persons AS P
            WHERE
                P.ADAccount IS NOT NULL
                AND P.Expired IS NULL
                AND P.Comment LIKE 'Imported FROM Azure AD:%'
                AND NOT EXISTS (
                    SELECT 1
                    FROM dbo.atbl_Tge_AzureAdUsers_Staging AS S
                    WHERE CAST(S.AzureID AS NVARCHAR(50)) = P.ADAccount
                )
        ) AS t
    ----------------------------------------------------- Expire users [END] --

    ------------------------------------------------ Un-Expire users [START] --
    DROP TABLE IF EXISTS #UsersToRevivify;
    CREATE TABLE #UsersToRevivify (ID INT)

    /*
     * Collect list
     */
    INSERT INTO #UsersToRevivify (ID)
    SELECT DISTINCT
        P.ID
    FROM
        dbo.stbl_System_Persons AS P
        INNER JOIN dbo.atbl_Tge_AzureAdUsers_Staging AS S
            ON CAST(S.AzureID AS NVARCHAR(50)) = P.ADAccount
    WHERE
        P.ADAccount IS NOT NULL
        AND P.Comment LIKE 'Imported FROM Azure AD:%'
        AND P.Expired IS NOT NULL
    ------------------------------------------------- Un-Expire users [END] --

    -- UPDATE Email, Names and ExternalId when changed from source: [START] --
    DROP TABLE IF EXISTS #UsersToUpdate;
    CREATE TABLE #UsersToUpdate (ID INT)

    /*
     * Collect list
     */
    INSERT INTO #UsersToUpdate (ID)
    SELECT DISTINCT
        P.ID
    FROM
        dbo.stbl_System_Persons AS P
        INNER JOIN dbo.atbl_Tge_AzureAdUsers_Staging AS S
            ON CAST(S.AzureID AS NVARCHAR(50)) = P.ADAccount
    WHERE
        (
            P.Email <> S.Email
            OR P.FirstName <> S.FirstName
            OR P.LastName <> S.LastName
        )
        AND S.Email IS NOT NULL
        AND P.ADAccount IS NOT NULL
    ----- UPDATE Email, Names and ExternalId when changed from source: [END] --

    -------------------------------------------- Insert PersonsUsers [START] --
    DECLARE
        @BaseURL nvarchar(255) = (
            select top 1 TDHost
            from dbo.stbl_Database_Setup
        ),
        @WebSite nvarchar(100)

    SELECT
        @BaseURL = CASE
            WHEN CHARINDEX('https://', @BaseURL) > 0
            THEN REPLACE(@BaseURL, 'https://', '')
            ELSE @BaseURL
        END

    SELECT @WebSite = SA.Alias
    FROM dbo.stbl_WebSiteCMS_SitesAliases AS SA
    WHERE SA.Alias = @BaseURL

    DROP TABLE IF EXISTS #LoginsToCreate;
    CREATE TABLE #LoginsToCreate (
        Person_ID int,
        UserType nvarchar(128),
        External_ID nvarchar(128),
        WebSite nvarchar(100)
    )

    /*
     * Collect list
     */
    INSERT INTO #LoginsToCreate
    (
        Person_ID,
        UserType,
        External_ID,
        WebSite
    )
        SELECT
            P.ID AS Person_ID,
            'Office 365' AS UserType,
            P.ADAccount AS External_ID,
            @WebSite AS WebSite
        FROM
            dbo.stbl_System_Persons AS P
            INNER JOIN dbo.atbl_TGE_AzureAdUsers_Staging AS S
                ON CAST(S.AzureID AS NVARCHAR(50)) = P.ADAccount
        WHERE
            (
                P.Expired IS NULL
                OR P.Expired > GETUTCDATE()
            )
            AND P.Deleted IS NULL
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.stbl_System_PersonsUsers AS PU
                WHERE
                    PU.UserType = 'Office 365'
                    AND PU.External_ID = P.ADAccount
                    AND PU.WebSite = @WebSite
            )

        union

            select
                null AS Person_ID,
                'Office 365' AS UserType,
                ADAccount AS External_ID,
                @WebSite AS WebSite
            from
                #NewUsers
    ---------------------------------------------- Insert PersonsUsers [END] --

    ----------------------------------------------- Grant Role Access [START]--
    DROP TABLE IF EXISTS #RolesToGrant;

    /*
     * Collect list
     */
    SELECT
        I.OrgUnit_ID,
        I.Role_ID,
        I.Person_ID,
        I.Comment
    INTO
        #RolesToGrant
    FROM
        (
                SELECT
                    P.OrgUnit_ID,
                    R.Role_ID,
                    Person_ID = P.ID,
                    Comment = 'Granted by Azure AD Import'
                FROM
                    dbo.stbl_System_Persons P
                    JOIN dbo.atbl_TGE_AzureAdUsers_Staging S
                        ON S.AzureID = TRY_CONVERT(UNIQUEIDENTIFIER, ADAccount)
                    JOIN dbo.atbl_TGE_AzureAdGroupsOrgUnits GOU
                        ON P.OrgUnit_ID = GOU.OrgUnit_ID
                        AND P.Email like '%@' + GOU.EmailDomain -- org unit is based user email domain
                    JOIN dbo.atbl_TGE_AzureAdGroupsOrgUnitsRoles R
                        ON R.AzureAdGroupsOrgUnits_ID = GOU.ID

            union

                select
                    N.OrgUnit_ID,
                    R.Role_ID,
                    Person_ID = null,
                    Comment = 'Granted by Azure AD Import'
                from
                    #NewUsers N
                    JOIN dbo.atbl_TGE_AzureAdUsers_Staging S
                        ON S.AzureID = TRY_CONVERT(UNIQUEIDENTIFIER, ADAccount)
                    JOIN dbo.atbl_TGE_AzureAdGroupsOrgUnits GOU
                        ON N.OrgUnit_ID = GOU.OrgUnit_ID
                        AND N.Email like '%@' + GOU.EmailDomain -- org unit is based user email domain
                    JOIN dbo.atbl_TGE_AzureAdGroupsOrgUnitsRoles R
                        ON R.AzureAdGroupsOrgUnits_ID = GOU.ID
            
        ) I
        LEFT JOIN dbo.stbl_System_OrgUnitsRoles OUR
            ON OUR.OrgUnit_ID = I.OrgUnit_ID
            AND OUR.Role_ID = I.Role_ID
            AND OUR.Person_ID = I.Person_ID
    WHERE
        OUR.ID IS NULL

    ------------------------------------------------ Grant Role Access [END] --

    select * from #NewUsers
    select * from #ExcludedUsersLogMessages
    select * from #UsersToExpire
    select * from #UsersToRevivify
    select * from #UsersToUpdate
    select * from #LoginsToCreate
    select * from #RolesToGrant
