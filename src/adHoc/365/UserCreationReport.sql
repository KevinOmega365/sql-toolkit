declare @OnThisDay date = '2025-01-22' -- '2024-12-13'

select
    P.Email,
    OUR.OrgUnit_ID,
    PU.UserType,
    OUR.Role_ID
    -- , *
from
    dbo.stbl_System_Persons P
    left join dbo.stbl_System_PersonsUsers PU
        on PU.Person_ID = P.ID
    left join dbo.stbl_System_OrgUnitsRoles OUR
        on OUR.Person_ID = P.ID
where
    P.CreatedBy_ID = 10010
    and cast(P.Created as date) = @OnThisDay
    
order by
    P.Email
