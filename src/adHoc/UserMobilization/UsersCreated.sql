select
    U.Login,
    P.CompanyId
from
    dbo.stbl_System_Users U with (nolock)
    join dbo.atbl_ProjectSetup_Persons P with (nolock)
        on U.Login = P.Login
where
    U.CreatedBy = 'af_Integrations_ServiceUser'

-- select
--     *
-- from
--     dbo.stbl_System_Users with (nolock)
-- where
--     Comments = 'Fabric for TiF (Tablet in Field)'

-- select
--     Count = count(*),
--     FirstCreated = min(Created),
--     LastCreated = max(Created)
-- from
--     dbo.stbl_System_Users with (nolock)
-- where
--     CreatedBy = 'af_Integrations_ServiceUser'

-- select
--     Count = count(*),
--     FirstCreated = min(Created),
--     LastCreated = max(Created)
-- from 
--     dbo.atbl_ProjectSetup_Persons with (nolock)
-- where
--     CreatedBy = 'af_Integrations_ServiceUser'