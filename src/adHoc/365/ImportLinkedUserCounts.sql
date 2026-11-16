-- select What = 'Persons', Count = count(*) from dbo.stbl_System_Persons

-- union all

select 'Graph Users', count(*) from dbo.atbl_TGE_AzureAdUsers_Staging

union all

select 'Linked Users', count(*) from dbo.atbl_TGE_AzureAdUsers_Staging as S join dbo.stbl_System_Persons as P on P.ADAccount = cast(S.AzureId as char(36))

union all

select
    'Potential Links', count(*)
from
    dbo.atbl_TGE_AzureAdUsers_Staging as S
    join dbo.stbl_System_PersonsUsers as U
        on U.External_ID = cast(S.AzureId as char(36))
    join dbo.stbl_System_Persons as P
        on P.ID = U.Person_ID
where
    P.ADAccount is null

union all

select 'Outliers', count(*)
from
    dbo.atbl_TGE_AzureAdUsers_Staging as S
    join dbo.stbl_System_Persons as P
        on P.Email = S.Email
    left join dbo.stbl_System_PersonsUsers as U
        on U.External_ID = cast(S.AzureId as char(36))
where
    U.ID is null
    and P.ADAccount is null
