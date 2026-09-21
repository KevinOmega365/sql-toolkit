/*
 * Remove Tab Whitespace
 */
DECLARE @tab CHAR(1) = CHAR(9)
SELECT
    Email,
    UserHasTab = CAST(
        CASE
            WHEN Email LIKE '%' + @tab + '%' THEN 1
            ELSE 0
        END AS BIT
    ),
    DisciplineLeadEmail,
    LeadHasTab = CAST(
        CASE
            WHEN DisciplineLeadEmail LIKE '%' + @tab + '%' THEN 1
            ELSE 0
        END AS BIT
    )
FROM
    (
        SELECT
            -- Yupp
            Email = REPLACE(Email, @tab, ''),
            DisciplineLeadEmail = REPLACE(DisciplineLeadEmail, @tab, '')
            -- -- Nope
            -- Email = rtrim(ltrim(Email)),
            -- DisciplineLeadEmail = rtrim(ltrim(DisciplineLeadEmail))
        FROM
            dbo.ltbl_Import_SharePointList_OnboardingListItems_SingleProjectLine WITH (NOLOCK)
        WHERE
            Email LIKE '%' + @tab + '%'
            OR DisciplineLeadEmail LIKE '%' + @tab + '%'
    ) T