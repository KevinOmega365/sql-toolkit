declare @rootObjectName nvarchar(256) = 'dbo.lstp_Import_DTS_DCS_Validate'

; with ObjectDependencyTree as (

    select
        ObjectName = @rootObjectName,
        ID = object_id(@rootObjectName),
        Depth = 0,
        ParentID = null,
        Path = cast('|' + cast(object_id(@rootObjectName) as nvarchar(11)) + '|' as nvarchar(max))

    union all
    
    select
        ObjectName = cast('dbo.' + referenced_entity_name as nvarchar(256)),
        ID = referenced_id,
        Depth = Depth + 1,
        ParentID = ObjectDependencyTree.ID,
        Path = ObjectDependencyTree.Path + cast(referenced_id as nvarchar(11))  + '|'
    from
        ObjectDependencyTree
        cross apply sys.dm_sql_referenced_entities(
            ObjectName,
            'OBJECT'
        )
    where
        ObjectDependencyTree.Path not like '%' + cast(referenced_id as nvarchar(11)) + '%'
)

select distinct * 
from ObjectDependencyTree
order by
    Depth,
    ObjectName
