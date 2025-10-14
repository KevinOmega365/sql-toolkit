/*
 *  Find API users
 */
SELECT
    [ID],
    [Person_ID],
    PersonName = (select Name from dbo.stbl_System_Persons P where P.ID = T1.[Person_ID]),
    [UserType],
    [External_ID]
FROM
    [dbo].[sviw_System_PersonsUsersWithSecAdmin] AS T1
WHERE
    [UserType] = 'ApiToken'
