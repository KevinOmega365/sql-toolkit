select top 10
    Pers.Login,
    Count = count(Pos.ID),
    PositionCreator = string_agg(Pos.CreatedBy, ', ')
from
    dbo.atbl_ProjectSetup_Persons Pers with (nolock)
    join dbo.atbl_Positions_PositionsPersons PosPers with (nolock)
        on PosPers.PersonID = Pers.PersonID
    join dbo.atbl_Positions_Positions Pos with (nolock)
        on Pos.ID = PosPers.Position_ID
where
    Pos.CreatedBy = 'af_Integrations_ServiceUser'
    and not exists (
        select *
        from dbo.ltbl_Import_TIF_PersonsPositions I with (nolock)
        where I.PES_LoginEmail = Pers.Login
    )
group by
    Pers.Login
order by
    newid()