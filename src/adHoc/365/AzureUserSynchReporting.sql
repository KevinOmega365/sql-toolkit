
----------------------------------------------------------- What have I done --

/*
 * Created count last n days
 */
declare @NumberOfDays int = 60 -- report over last n days
select
    Dates.Date,
    Persons = Persons.Count,
    PersonsUsers = PersonsUsers.Count,
    OrgUnitsRoles = OrgUnitsRoles.Count
from
(
    SELECT
        Date = CAST(DATEADD(DAY, 1 - Number, getdate()) as date)
    FROM
        (
            SELECT
                ROW_NUMBER() OVER (ORDER BY c.object_id) AS Number
            FROM
            sys.columns c
        ) Numbers
    WHERE
        Number <= @NumberOfDays
) Dates
left join (
    select
        Date = cast(Created as date),
        Count = count(*)
    from dbo.stbl_System_Persons P
    where
        CreatedBy_ID = 10010
    group by
        cast(Created as date)
) Persons
    on Persons.Date = Dates.Date
left join (
    select
        Date = cast(Created as date),
        Count = count(*)
    from dbo.stbl_System_PersonsUsers PU
    where
        CreatedBy_ID = 10010
    group by
        cast(Created as date)
) PersonsUsers
    on PersonsUsers.Date = Dates.Date
left join (
    select
        Date = cast(Created as date),
        Count = count(*)
    from dbo.stbl_System_OrgUnitsRoles OUR
    where
        CreatedBy_ID = 10010
    group by
        cast(Created as date)
) OrgUnitsRoles
    on OrgUnitsRoles.Date = Dates.Date
order by
    Dates.Date desc

-------------------------------------------------------------------------------

/*
 * What would happen?
 */

-------------------------------------------------------------------------------

/*
 * Run State
 */
-- select
--     IsOk = cast(case when ErrorMessage is null and ErrorStackTrace is null then 1 else 0 end as bit)
--     , LastRun
--     , ErrorMessage
--     , ErrorStackTrace
-- from
--     dbo.atbl_TGE_AzureAdGroups

/* 
 * Log messages 
 */
-- select
--     RunID = json_value(LogMessage, '$.RunID')
--     , TYPE = json_value(LogMessage, '$.TYPE')
--     , Message = json_value(LogMessage, '$.Message')
--     , Data  = json_query(LogMessage, '$.StageData')
-- from
--     dbo.atbl_TGE_AzureAdUsers_Log
