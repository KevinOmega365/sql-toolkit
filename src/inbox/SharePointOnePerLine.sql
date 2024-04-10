
DROP TABLE IF EXISTS #JsonRows
DROP TABLE IF EXISTS #PersonsProjects
DROP TABLE IF EXISTS #PersonsDisciplineLeads

DECLARE @ListGroupID INT = 1

SELECT
    SourceJson = VALUE,
    PrimKey = NEWID()
INTO
    #JsonRows
FROM
    dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
    CROSS APPLY OPENJSON(JSON_DATA, '$.value')

-- select count(distinct PrimKey)
-- from #JsonRows

SELECT
    ProjectID = JSON_VALUE(ProjectArray.VALUE, '$.LookupId'),
    ArrayIndex = ProjectArray.[KEY],
    JsonRowRef = JsonRows.PrimKey
INTO
    #PersonsProjects
FROM
    #JsonRows JsonRows
    CROSS APPLY OPENJSON( JSON_QUERY(JsonRows.SourceJson, '$.fields.Project') ) ProjectArray

-- select count(distinct JsonRowRef)
-- from #PersonsProjects

SELECT
    DisciplineLeadEmail = JSON_VALUE(DisciplineLeadArray.VALUE, '$.Email'),
    ArrayIndex = DisciplineLeadArray.[KEY],
    JsonRowRef = JsonRows.PrimKey
INTO
    #PersonsDisciplineLeads
FROM
    #JsonRows JsonRows
    CROSS APPLY OPENJSON( JSON_QUERY(SourceJson, '$.fields.DisciplineLead') ) DisciplineLeadArray

-- select count(distinct JsonRowRef)
-- from #PersonsDisciplineLeads

insert into dbo.ltbl_Import_SharePointList_OnboardingListItems_STAGING 
(
    SourceJson,
    LastName,
    FirstName,
    Email,
    MobileNo,
    RoleID,
    Discipline,
    DisciplineLead,
    DisciplineLeadEmail,
    Company,
    ProjectIdList,
    ProjectID,
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
    SourceGuid, -- GUID is no longer available
    SharePointListGroupID,
    ID
)
select
    SourceJson,
    LastName = json_value(SourceJson, '$.fields.Lastname'),
    FirstName = json_value(SourceJson, '$.fields.Title'),
    Email = json_value(SourceJson, '$.fields.E_x002d_mail'),
    MobileNo = json_value(SourceJson, '$.fields.Phoneno'),
    RoleID = json_value(SourceJson, '$.fields.RoleLookupId'),
    Discipline = json_value(SourceJson, '$.fields.Discipline'),
    DisciplineLead = (
        coalesce((
            select string_agg(Email, ', ')
            from (
                select Email = json_value(value, '$.Email')
                from openjson( json_query(SourceJson, '$.fields.DisciplineLead') ) 
            ) T
        ), json_value(SourceJson, '$.fields.Discipline_x0020_Lead'))
    ),
    DisciplineLeadEmail = PersonsDisciplineLeads.DisciplineLeadEmail,
    Company = json_value(SourceJson, '$.fields.Company'),
    ProjectIdList = (
    
        select ProjectIdList = '[' + string_agg(LookupId, ', ') within group ( order by LookupId ) + ']'
        from (
            select LookupId = json_value(value, '$.LookupId')
            from openjson( json_query(SourceJson, '$.fields.Project') ) 
        ) T
    ),
    ProjectID = PersonsProjects.ProjectID,
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
    AzureAdIsActive = cast(case when json_value(SourceJson, '$.fields.AADActive') = 'True' then 1 else 0 end as bit),
    IsSupportingPosition = cast(case when isnull(json_value(SourceJSON, '$.fields.Supporting_x0020_Position'), 'false') = 'false' then 0 else 1 end as bit),
    SourceGuid = newid(), -- GUID is no longer available
    SharePointListGroupID = @ListGroupID,
    ID = cast(json_value(SourceJson, '$.id') as int)
from
    #JsonRows JsonRows
    join #PersonsProjects PersonsProjects
        on PersonsProjects.JsonRowRef = JsonRows.PrimKey
    left join #PersonsDisciplineLeads PersonsDisciplineLeads
        on PersonsDisciplineLeads.JsonRowRef = PersonsProjects.JsonRowRef
        and PersonsDisciplineLeads.ArrayIndex = PersonsProjects.ArrayIndex
