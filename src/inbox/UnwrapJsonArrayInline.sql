DECLARE @ListGroupID INT = 1

    SELECT
        LastName = json_value(SourceJson, '$.fields.Lastname'),
        FirstName = json_value(SourceJson, '$.fields.Title'),
        Email = json_value(SourceJson, '$.fields.E_x002d_mail'),
        MobileNo = json_value(SourceJson, '$.fields.Phoneno'),
        RoleID = json_value(SourceJson, '$.fields.RoleLookupId'),
        Discipline = json_value(SourceJson, '$.fields.Discipline'),
        DisciplineLead = json_value(SourceJson, '$.fields.Discipline_x0020_Lead'),
        Company = json_value(SourceJson, '$.fields.Company'),
        ProjectIdList = (
        
            select ProjectIdList = '[' + string_agg(LookupId, ', ') within group ( order by LookupId ) + ']'
            from (
                select LookupId = json_value(value, '$.LookupId')
                from openjson( json_query(SourceJson, '$.fields.Project') ) 
            ) T

        ),
        OfficeLocation = json_value(SourceJson, '$.fields.Officelocation'),
        SecondaryOfficeLocation = json_value(SourceJson, '$.fields.Secondary_x0020_office_x0020_loc'),
        AccessCardRequired = json_value(SourceJson, '$.fields.Access_x0020_card_x0020_required'),
        SourceModified = json_value(SourceJson, '$.fields.Modified'),
        SourceCreated = json_value(SourceJson, '$.fields.Created'),
        OldProjectIdList = (
        
            select ProjectIdList = '[' + string_agg(LookupId, ', ') within group ( order by LookupId ) + ']'
            from (
                select LookupId = json_value(value, '$.LookupId')
                from openjson( json_query(SourceJson, '$.fields.OldProject') ) 
            ) T

        ),
        AccessToAllianceOfficeArea = json_value(SourceJson, '$.fields.Access_x0020_to_x0020_building'),
        AzureAdUPN = json_value(SourceJson, '$.fields.AADupn'),
        AzureAdIsActive = json_value(SourceJson, '$.fields.AADActive'),
        IsSupportingPosition = case when isnull(json_value(SourceJSON, '$.fields.Supporting_x0020_Position'), 'false') = 'false' then 0 else 1 end,
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
                existing.ID = json_value(import.SourceJSON, '$.id')
                AND existing.SharePointListGroupID = @ListGroupID
        )