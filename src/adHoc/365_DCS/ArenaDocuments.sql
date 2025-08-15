
select
    OrgUnit_ID,
    OrgUnit = (
        select Name
        from dbo.stbl_System_OrgUnits OU
        where OU.ID = D.OrgUnit_ID
    ),
    Count = count(*)
from
    dbo.atbl_Arena_Documents D
group by
    OrgUnit_ID
order by
    Count desc

select count(*) from sys.columns where object_name(object_id) = 'atbl_Arena_Documents'

select name, type = type_name(system_type_id)
from sys.columns
where object_name(object_id) = 'atbl_Arena_Documents'
order by column_id

select count(*) from dbo.atbl_Arena_Documents
