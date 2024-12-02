declare @namePattern nvarchar(128) = '%azuread%'

/*
 * Tables views and procedures
 */
select name
from sys.objects
where
    name like @namePattern
    and type not in ('d', 'f', 'pk', 'tr', 'uq')
order by
    name

/*
 * Counts by type
 */
-- select
--     count(*) count,
--     type_desc,
--     type
-- from
--     sys.objects
-- where
--     name like @namePattern
--     and type not in ('d', 'f', 'pk', 'tr', 'uq')
-- group by
--     type_desc,
--     type

/*
 * Counts
 */
-- select count(*)
-- from sys.objects
-- where name like @namePattern
