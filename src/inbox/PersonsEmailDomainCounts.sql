select
    EmailDomain,
    Count = count(*)
from
    (
        select
            Email,
            EmailDomain = substring(
                Email,
                charindex('@', Email),
                len(Email) - charindex('@', Email) + 1
            )
        from
            dbo.stbl_System_Persons
    ) T
group by
    EmailDomain
order by
    EmailDomain
