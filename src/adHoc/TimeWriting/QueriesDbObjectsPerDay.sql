select
    Count = sum(ObjectQueryCount),
    CreatedDate,
    Objects = string_agg(ObjectID, ', ')
        within group (order by ObjectQueryCount desc)
from
    (
        select
            CreatedDate = cast(Created as date),
            ObjectQueryCount = count(*),
            ObjectID
        from
            dbo.stbv_DbTools_Scripts
        where
            CreatedBy = suser_sname()
            and Created > '2026-04-01'
        group by
            cast(Created as date),
            ObjectID
    ) T
group by
    CreatedDate
order by
    CreatedDate desc
