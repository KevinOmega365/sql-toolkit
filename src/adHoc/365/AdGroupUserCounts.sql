
/*
 * Users Group Membership
 */
select
    GroupCount,
    UsersWithMebersCount = count(*)
from (
    select
        AAU.Email,
        GroupCount = count(*)
    from
        dbo.atbl_TGE_AzureAdGroupsMembers AAGM
        join dbo.atbl_TGE_AzureAdGroups AAG
            on AAG.ID = AzureAdGroup_ID
        join dbo.atbl_TGE_AzureAdUsers_Staging AAU
            on AAU.ID = AAGM.Users_Staging_ID
    group by
        AAU.Email
) T
group by
    GroupCount
order by
    GroupCount


/*
 * Groups User Counts
 */
select
    AAG.Name,
    UserCount = count(AAGM.Users_Staging_ID)
from
    dbo.atbl_TGE_AzureAdGroupsMembers AAGM
    join dbo.atbl_TGE_AzureAdGroups AAG
        on AAG.ID = AzureAdGroup_ID
    join dbo.atbl_TGE_AzureAdUsers_Staging AAU
        on AAU.ID = AAGM.Users_Staging_ID
group by
    AAG.Name
order by
    AAG.Name


/*
 * Users with one group membership
 */
select
    AAU.Email,
    GroupMembership = string_agg(AAG.Name, ':-)')
from
    dbo.atbl_TGE_AzureAdGroupsMembers AAGM
    join dbo.atbl_TGE_AzureAdGroups AAG
        on AAG.ID = AzureAdGroup_ID
    join dbo.atbl_TGE_AzureAdUsers_Staging AAU
        on AAU.ID = AAGM.Users_Staging_ID
group by
    AAU.Email
having
    count(*) < 2
order by
    AAU.Email
