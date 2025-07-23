/*
 * Users Group Membership
 */
select
    AAU.Email,
    GroupList = '["' + string_agg(AAG.Name, '", "') + '"]'
from
    dbo.atbl_TGE_AzureAdGroupsMembers AAGM
    join dbo.atbl_TGE_AzureAdGroups AAG
        on AAG.ID = AzureAdGroup_ID
    join dbo.atbl_TGE_AzureAdUsers_Staging AAU
        on AAU.ID = AAGM.Users_Staging_ID
group by
    AAU.Email
order by
    AAU.Email
