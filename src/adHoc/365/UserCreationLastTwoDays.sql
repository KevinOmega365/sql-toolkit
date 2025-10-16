/*
 * Persons details
 */
SELECT
    CreatorName = (
        SELECT
            FirstName + ' ' + LastName
        FROM
            dbo.stbl_System_Persons C
        WHERE
            C.ID = P.CreatedBy_ID
    ),
    *
FROM
    dbo.stbl_System_Persons P
WHERE
    Created > CAST(DATEADD(day, -2, GETDATE()) AS DATE)
ORDER BY
    Created DESC

/*
 * Persons count
 */
-- select Count = count(*) from dbo.stbl_System_Persons where Created > cast(dateadd(day, -2, getdate()) as date)

/*
 * Person-users details
 */
SELECT
    CreatorName = (
        SELECT
            FirstName + ' ' + LastName
        FROM
            dbo.stbl_System_Persons C
        WHERE
            C.ID = PU.CreatedBy_ID
    ),
    *
FROM
    dbo.stbl_System_PersonsUsers PU
WHERE
    Created > CAST(DATEADD(day, -2, GETDATE()) AS DATE)
ORDER BY
    Created DESC

/*
 * Person-users count
 */
-- select Count = count(*) from dbo.stbl_System_PersonsUsers where Created > cast(dateadd(day, -2, getdate()) as date)
