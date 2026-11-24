SELECT
    LoginCount = (
        SELECT
            COUNT(*)
        FROM
            dbo.stbl_System_PersonsUsers U
        WHERE
            U.Person_ID = P.ID
    ),
    *
FROM
    dbo.stbl_System_Persons P
WHERE
    Email IN (
        'jane.doe@a-domain.wat',
        'ole.norman@a-domain.wat'
    )