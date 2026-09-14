/*
 * Review vendors persons positions companies
 */
select
    Count = count(*),
    Pos_CreatedBy = Pos.CreatedBy,
    Pos_UpdatedBy = Pos.UpdatedBy,
    Pos_CompanyID = Pos.CompanyID,
    Pers_CreatedBy = Pers.CreatedBy,
    Pers_UpdatedBy = Pers.UpdatedBy,
    Pers_CompanyID = Pers.CompanyID,
    I.vendor
from
    dbo.atbl_Positions_Positions AS Pos with (nolock)
    join dbo.atbl_Positions_PositionsPersons PosPers with (nolock)
        on PosPers.Position_ID = Pos.ID
    join dbo.atbl_ProjectSetup_Persons Pers with (nolock)
        on Pers.PersonID = PosPers.PersonID
    join dbo.stbl_System_Users Usr with (nolock)
        on Usr.Login = Pers.Login
    left join dbo.ltbl_Import_TIF_PersonsPositions I with (nolock)
        on I.company_email = Usr.Login
where
    Pos.CreatedBy = 'af_Integrations_ServiceUser'
    and Usr.Login <> 'leila.beig@capgemini.com'
    and I.vendor is not null
group by
    Pos.CreatedBy,
    Pos.UpdatedBy,
    Pos.CompanyID,
    Pers.CreatedBy,
    Pers.UpdatedBy,
    Pers.CompanyID,
    I.vendor