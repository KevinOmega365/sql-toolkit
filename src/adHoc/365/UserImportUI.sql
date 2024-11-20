
-- dbo.astp_Tge_AzureAdUsers_ReloadStaging

select
    atbl_TGE_AzureAdGroups = (select count(*) from dbo.atbl_TGE_AzureAdGroups),
    atbl_TGE_AzureAdGroupsMembers = (select count(*) from dbo.atbl_TGE_AzureAdGroupsMembers),
    atbl_TGE_AzureAdUsers_Raw = (select count(*) from dbo.atbl_TGE_AzureAdUsers_Raw),
    atbl_TGE_AzureAdUsers_Staging = (select count(*) from dbo.atbl_TGE_AzureAdUsers_Staging)

delete dbo.atbl_TGE_AzureAdGroupsMembers
delete dbo.atbl_TGE_AzureAdUsers_Raw
delete dbo.atbl_TGE_AzureAdUsers_Staging

-- insert into dbo.atbl_TGE_AzureAdGroups (Name,Description,AzureID)
-- values ('AZURE_ZscalerApp_Key_Users','Azure Group for Zscaler Client connector Pilot','ea12262d-e5aa-40f3-81c9-5d9a4c869a5f')
