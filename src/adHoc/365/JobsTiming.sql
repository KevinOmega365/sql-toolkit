select
    Name
    , Type
    , CronExpression
    -- , LastRun
from
    [dbo].[sviw_O365_Jobs]
where
    Name like '%azuread%'
order by
    LastRun
