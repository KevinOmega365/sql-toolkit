
/*
 * Who is creating all of the pieces
 */
select
    Count = count(*),
    Pos_CreatedBy = Pos.CreatedBy,
    PosPers_CreatedBy = PosPers.CreatedBy,
    Pers_CreatedBy = Pers.CreatedBy,
    Usr_CreatedBy = Usr.CreatedBy
from 
    dbo.atbl_Positions_Positions AS Pos WITH (NOLOCK)
    JOIN dbo.atbl_Positions_PositionsPersons PosPers WITH (NOLOCK)
        ON PosPers.Position_ID = Pos.ID
    JOIN dbo.atbl_ProjectSetup_Persons Pers WITH (NOLOCK)
        ON Pers.PersonID = PosPers.PersonID
    join dbo.stbl_System_Users Usr with (nolock)
        on Usr.Login = Pers.Login
    left join dbo.ltbl_Import_TIF_Positions as I with (nolock)
        on I.PES_Position_ID = Pos.ID
where
    Pos.CreatedBy = 'af_Integrations_ServiceUser'
group by
    Pos.CreatedBy,
    PosPers.CreatedBy,
    Pers.CreatedBy,
    Usr.CreatedBy
order by
    count(*) desc
