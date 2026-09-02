
/*
 *  Exploring Positions, Persons and Companies
 */
select
    -- Count = count(distinct Pos.ID) -- count(*)
    Pos.Created,
    Pos.ID,
    Pos.CompanyID,
    Pers.PersonID,
    Pers.CreatedBy,
    Pers.CompanyID,
    Usr.Login,
    Usr.Comments
from 
    dbo.atbl_Positions_Positions AS Pos WITH (NOLOCK)
    JOIN dbo.atbl_Positions_PositionsPersons PosPers WITH (NOLOCK)
        ON PosPers.Position_ID = Pos.ID
    JOIN dbo.atbl_ProjectSetup_Persons Pers WITH (NOLOCK)
        ON Pers.PersonID = PosPers.PersonID
    join dbo.stbl_System_Users Usr with (nolock)
        on Usr.Login = Pers.Login
where
    Pos.CreatedBy = 'af_Integrations_ServiceUser'
    and Pos.CompanyID is null
    -- and Pers.CompanyID is not null
    -- and Usr.Login not like '%akersolutions.com'

/*
 * All the positions we've created
 */
-- select count(*)
-- from dbo.atbl_Positions_Positions with (nolock)
-- where CreatedBy = 'af_Integrations_ServiceUser'