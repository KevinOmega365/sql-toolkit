
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

select *
from
    (
        select
            LastName = json_value(SourceJson, '$.fields.Lastname'),
            FirstName = json_value(SourceJson, '$.fields.Title'),
            Email = json_value(SourceJson, '$.fields.E_x002d_mail'),
            DisciplineLead = (
                coalesce((
                    select string_agg(Email, ', ')
                    from (
                        select Email = json_value(value, '$.Email')
                        from openjson( json_query(SourceJson, '$.fields.DisciplineLead') ) 
                    ) T

                ), json_value(SourceJson, '$.fields.Discipline_x0020_Lead'))
            ),
            ProjectIdList = (
            
                select ProjectIdList = '[' + string_agg(LookupId, ', ') within group ( order by LookupId ) + ']'
                from (
                    select LookupId = json_value(value, '$.LookupId')
                    from openjson( json_query(SourceJson, '$.fields.Project') ) 
                ) T

            ),
            DisciplineLeadEmailCount = (
                select count(*)
                from OPENJSON( JSON_QUERY(SourceJson, '$.fields.DisciplineLead') )
            ),
            ProjectCount = (
                select count(*)
                from OPENJSON( JSON_QUERY(JsonRows.SourceJson, '$.fields.Project') )
            ),
            PersonsProjects.ProjectID,
            ProjectTitle = (
                select Title
                from dbo.ltbl_Import_SharePointList_ProjectsListItems as P with (nolock)
                where P.ID = PersonsProjects.ProjectId
            ),
            PersonsDisciplineLeads.DisciplineLeadEmail,
            ProjectListIndex = PersonsProjects.ArrayIndex,
            JsonRows.Primkey
        from
            #JsonRows JsonRows
            join #PersonsProjects PersonsProjects
                on PersonsProjects.JsonRowRef = JsonRows.PrimKey
            left join #PersonsDisciplineLeads PersonsDisciplineLeads
                on PersonsDisciplineLeads.JsonRowRef = PersonsProjects.JsonRowRef
                and PersonsDisciplineLeads.ArrayIndex = PersonsProjects.ArrayIndex
            
    ) AWESOME_TABLE_ALIAS_FTW
-- where
--     ProjectCount > 1
--     and DisciplineLeadEmailCount <> ProjectCount
order by
    LastName,
    FirstName,
    Email,
    ProjectListIndex
    
