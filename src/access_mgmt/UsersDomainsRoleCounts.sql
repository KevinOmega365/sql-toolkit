
/*
 * Users (count) created by af_Integrations_ServiceUser
 */
-- select count(*) as Count
-- from dbo.stbl_System_Users with (nolock)
-- where CreatedBy like 'af_Integr%'

/*
 * Users (details) created by af_Integrations_ServiceUser
 */
-- select *
-- from dbo.stbl_System_Users with (nolock)
-- where CreatedBy like 'af_Integr%'

/*
 * Users Domains Roles count
 * NB: this doesn't cover domain-less roles
 *     or users with no roles
 */
select
    Login,
    DomainsRoles = '[ ' +
        string_agg('{ "domain": "' + Domain + '", roleCount: ' + cast(RoleCount as nvarchar(4)) + ' }', ', ')
        within group (order by Domain) +
        ' ]'
from
    (
        select
            U.Login,
            RMD.Domain,
            count(*) as RoleCount
        from
            dbo.stbl_System_Users as U with (nolock)
            join dbo.stbl_System_RolesMembersDomains AS RMD WITH (NOLOCK)
                on RMD.Login = U.Login
        where
            U.CreatedBy like 'af_Integr%'
        group by
            U.Login,
            RMD.Domain
    ) T
group by
    Login
order by
    Login