
declare @azure_groups nvarchar(max) = '[
    {
        "id": "5a334b19-236d-415c-902b-cb1b8458c8a7",
        "description": "Dynamic group with all users from some subsidiary",
        "displayName": "AZURE_Omega_XYZ123"
    }
]'

-- insert into dbo.atbl_TGE_AzureAdGroups
-- (
--     AzureID,
--     Description,
--     Name
-- )
select
    AzureID,
    Description,
    Name
from
    openjson(@azure_groups) with
    (
        AzureID uniqueidentifier '$.id',
        Description nvarchar(max) '$.description',
        Name nvarchar(max) '$.displayName'
    )
    GroupsToAdd
where
    not exists
    (
        select *
        from dbo.atbl_TGE_AzureAdGroups ExistingGroups
        where ExistingGroups.AzureID = GroupsToAdd.AzureID
    )

/*
 * reference
 */
SELECT
    PrimKey,
    ID,
    Created,
    CreatedBy_ID,
    Updated,
    UpdatedBy_ID,
    AzureGroupEmail,
    Name,
    Description,
    Deprecated,
    ErrorMessage,
    ErrorStackTrace,
    LastRun,
    AzureID
FROM
    dbo.atbl_TGE_AzureAdGroups
