DECLARE @ListGroupID INT = 1

select top 50
    ShiteSolution = (
        coalesce((
            select string_agg(Email, ', ')
            from (
                select Email = json_value(value, '$.Email')
                from openjson( json_query(SourceJson, '$.fields.DisciplineLead') ) 
            ) T

        ), json_value(SourceJson, '$.fields.Discipline_x0020_Lead'))
    ),
    MixedDisciplineLead = coalesce(json_query(SourceJson, '$.fields.DisciplineLead'), json_value(SourceJson, '$.fields.Discipline_x0020_Lead')),
    OldDisciplineLead = json_value(SourceJson, '$.fields.Discipline_x0020_Lead'),
    NewDisciplineLead = json_query(SourceJson, '$.fields.DisciplineLead'),
    UnpackedLeaders = (
            select string_agg(Email, ', ')
            from (
                select Email = json_value(value, '$.Email')
                from openjson( json_query(SourceJson, '$.fields.DisciplineLead') ) 
            ) T

        ),
    ProjectIdList = (
    
        select ProjectIdList = '[' + string_agg(LookupId, ', ') within group ( order by LookupId ) + ']'
        from (
            select LookupId = json_value(value, '$.LookupId')
            from openjson( json_query(SourceJson, '$.fields.Project') )
        ) T

    )
    ,SourceJSON
from
    (
        SELECT SourceJSON = value
        FROM
            dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
            CROSS APPLY OPENJSON(JSON_DATA, '$.value')
    ) AS import

order by newid()