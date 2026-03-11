
/*
 * shared
 */
declare @DbObjectName nvarchar(128) = 'lstp_Import_SharePointList_CreateUser_SPL'

drop table if exists #OnboardingReferences

select *
into #OnboardingReferences
from sys.dm_sql_referenced_entities('dbo.' + @DbObjectName, 'OBJECT')

/*
 * tablular
 */
select
    [objectName] = referenced_entity_name,
    [columnsRead] = (
        select
            '[' + 
            string_agg('"' + referenced_minor_name + '"', ', ') within group (order by C.referenced_minor_name)
            + ']'
        from
            #OnboardingReferences C
        where
            C.referenced_entity_name = O.referenced_entity_name
            and C.referenced_minor_name is not null
            and is_selected = 1
    ),
    [columnsWritten] = (
        select
            '[' + 
            string_agg('"' + referenced_minor_name + '"', ', ') within group (order by C.referenced_minor_name)
            + ']'
        from
            #OnboardingReferences C
        where
            C.referenced_entity_name = O.referenced_entity_name
            and C.referenced_minor_name is not null
            and C.is_updated = 1
    )
from
    #OnboardingReferences O
group by
    referenced_entity_name
order by
    referenced_entity_name

/*
 * JSON
 */
select
    [objectName] = referenced_entity_name,
    [columnsRead] = (
        select
            [columnName] = referenced_minor_name
        from
            #OnboardingReferences C
        where
            C.referenced_entity_name = O.referenced_entity_name
            and C.referenced_minor_name is not null
            and is_selected = 1
        for
            json path
    ),
    [columnsWritten] = (
        select
            [columnName] = referenced_minor_name
        from
            #OnboardingReferences C
        where
            C.referenced_entity_name = O.referenced_entity_name
            and C.referenced_minor_name is not null
            and C.is_updated = 1
        for
            json path
    )
from
    #OnboardingReferences O
group by
    referenced_entity_name
order by
    referenced_entity_name
for json path
