CREATE OR ALTER PROCEDURE [dbo].[lstp_Import_SharePointList_UpsertOnboardingListItems] (
    @GroupRef UNIQUEIDENTIFIER, -- Used to tag records and log entries with the PrimKey of the group (INTEGR_REC_GROUPREF)
    @TaskRef UNIQUEIDENTIFIER,  -- Used to tag records and log entries with the PrimKey of the current group-task
    @BatchRef UNIQUEIDENTIFIER  -- Used to tag all records and log entries across a group execution run (INTEGR_REC_BATCHREF)
)    
AS 
BEGIN

    DECLARE @ListGroupID INT = 1

    ---------------------------------------------------------------------------

    UPDATE existing
    SET
        LastName = json_value(SourceJson, '$.Lastname'),
        FirstName = json_value(SourceJson, '$.Title'),
        Email = json_value(SourceJson, '$.E_x002d_mail'),
        MobileNo = json_value(SourceJson, '$.Phoneno'),
        RoleID = json_value(SourceJson, '$.RoleId'),
        Discipline = json_value(SourceJson, '$.Discipline'),
        DisciplineLead = json_value(SourceJson, '$.Discipline_x0020_Lead'),
        Company = json_value(SourceJson, '$.Company'),
        ProjectIdList = json_query(SourceJson, '$.ProjectId'),
        OfficeLocation = json_value(SourceJson, '$.Officelocation'),
        SecondaryOfficeLocation = json_value(SourceJson, '$.Secondary_x0020_office_x0020_loc'),
        AccessCardRequired = json_value(SourceJson, '$.Access_x0020_card_x0020_required'),
        SourceModified = json_value(SourceJson, '$.Modified'),
        SourceCreated = json_value(SourceJson, '$.Created'),
        OldProjectIdList = json_query(SourceJson, '$.OldProjectId'),
        AccessToAllianceOfficeArea = json_value(SourceJson, '$.Access_x0020_to_x0020_building'),
        AzureAdUPN = json_value(SourceJson, '$.AADupn'),
        AzureAdIsActive = json_value(SourceJson, '$.AADActive'),
        IsSupportingPosition = case when isnull(json_value(SourceJSON, '$.Supporting_x0020_Position'), 'false') = 'false' then 0 else 1 end,
        IsRemovedFromSource = 0
    FROM
        dbo.ltbl_Import_SharePointList_OnboardingListItems AS existing WITH (NOLOCK)
        JOIN (
            SELECT SourceJSON = value
            FROM
                dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
                CROSS APPLY OPENJSON(JSON_DATA, '$.value')
        ) AS import
            ON json_value(import.SourceJSON, '$.id') = existing.ID
            AND existing.SharePointListGroupID = @ListGroupID
    WHERE
        LastName <> json_value(SourceJson, '$.Lastname')
        OR FirstName <> json_value(SourceJson, '$.Title')
        OR Email <> json_value(SourceJson, '$.E_x002d_mail')
        OR MobileNo <> json_value(SourceJson, '$.Phoneno')
        OR RoleID <> json_value(SourceJson, '$.RoleId')
        OR Discipline <> json_value(SourceJson, '$.Discipline')
        OR DisciplineLead <> json_value(SourceJson, '$.Discipline_x0020_Lead')
        OR Company <> json_value(SourceJson, '$.Company')
        OR ProjectIdList <> json_query(SourceJson, '$.ProjectId')
        OR OfficeLocation <> json_value(SourceJson, '$.Officelocation')
        OR SecondaryOfficeLocation <> json_value(SourceJson, '$.Secondary_x0020_office_x0020_loc')
        OR AccessCardRequired <> json_value(SourceJson, '$.Access_x0020_card_x0020_required')
        OR SourceModified <> json_value(SourceJson, '$.Modified')
        OR SourceCreated <> json_value(SourceJson, '$.Created')
        OR OldProjectIdList <> json_query(SourceJson, '$.OldProjectId')
        OR AccessToAllianceOfficeArea <> json_value(SourceJson, '$.Access_x0020_to_x0020_building')
        OR AzureAdUPN = json_value(SourceJson, '$.AADupn')
        OR AzureAdIsActive = json_value(SourceJson, '$.AADActive')
        OR IsSupportingPosition <> case when isnull(json_value(SourceJSON, '$.Supporting_x0020_Position'), 'false') = 'false' then 0 else 1 end
        OR existing.IsRemovedFromSource = 1

    ---------------------------------------------------------------------------

    INSERT INTO dbo.ltbl_Import_SharePointList_OnboardingListItems (
        LastName,
        FirstName,
        Email,
        MobileNo,
        RoleID,
        Discipline,
        DisciplineLead,
        Company,
        ProjectIdList,
        OfficeLocation,
        SecondaryOfficeLocation,
        AccessCardRequired,
        SourceModified,
        SourceCreated,
        OldProjectIdList,
        AccessToAllianceOfficeArea,
        AzureAdUPN,
        AzureAdIsActive,
        IsSupportingPosition,
        -- SourceGuid, -- GUID is no longer available
        SharePointListGroupID
    )
    SELECT
        LastName = json_value(SourceJson, '$.Lastname'),
        FirstName = json_value(SourceJson, '$.Title'),
        Email = json_value(SourceJson, '$.E_x002d_mail'),
        MobileNo = json_value(SourceJson, '$.Phoneno'),
        RoleID = json_value(SourceJson, '$.RoleId'),
        Discipline = json_value(SourceJson, '$.Discipline'),
        DisciplineLead = json_value(SourceJson, '$.Discipline_x0020_Lead'),
        Company = json_value(SourceJson, '$.Company'),
        ProjectIdList = json_query(SourceJson, '$.ProjectId'),
        OfficeLocation = json_value(SourceJson, '$.Officelocation'),
        SecondaryOfficeLocation = json_value(SourceJson, '$.Secondary_x0020_office_x0020_loc'),
        AccessCardRequired = json_value(SourceJson, '$.Access_x0020_card_x0020_required'),
        SourceModified = json_value(SourceJson, '$.Modified'),
        SourceCreated = json_value(SourceJson, '$.Created'),
        OldProjectIdList = json_query(SourceJson, '$.OldProjectId'),
        AccessToAllianceOfficeArea = json_value(SourceJson, '$.Access_x0020_to_x0020_building'),
        AzureAdUPN = json_value(SourceJson, '$.AADupn'),
        AzureAdIsActive = json_value(SourceJson, '$.AADActive'),
        IsSupportingPosition = case when isnull(json_value(SourceJSON, '$.Supporting_x0020_Position'), 'false') = 'false' then 0 else 1 end,
        -- SourceGuid = json_value(SourceJson, '$.GUID'), -- GUID is no longer available
        SharePointListGroupID = @ListGroupID
    FROM
        (
            SELECT SourceJSON = value
            FROM
                dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
                CROSS APPLY OPENJSON(JSON_DATA, '$.value')
        ) AS import
    WHERE
        NOT EXISTS (
            SELECT *
            FROM dbo.ltbl_Import_SharePointList_OnboardingListItems AS existing WITH (NOLOCK)
            WHERE
                existing.ID = json_value(import.SourceJSON, '$.id') -- GUID is no longer available
                AND existing.SharePointListGroupID = @ListGroupID
        )

    ---------------------------------------------------------------------------

    UPDATE existing 
    SET IsRemovedFromSource = 1
    FROM
        dbo.ltbl_Import_SharePointList_OnboardingListItems AS existing WITH (NOLOCK)
    WHERE
        NOT EXISTS (
            SELECT *
            FROM (
                SELECT SourceJSON = value
                FROM
                    dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
                    CROSS APPLY OPENJSON(JSON_DATA, '$.value')
            ) AS import
            WHERE json_value(import.SourceJSON, '$.id') = existing.ID
        )
        AND existing.SharePointListGroupID = @ListGroupID

END
