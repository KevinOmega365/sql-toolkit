-- select
--     Count = count(*),
--     ClientAcceptanceCode
-- from
--     dbo.atbl_DCS_Revisions with (nolock)
-- group by
--     ClientAcceptanceCode

-- select
--     ClientAcceptanceCode,
--     ClientAcceptanceCodeStringDefinition = '"' + ClientAcceptanceCode + '"',
--     Domains = '["' + string_agg(Domain, '", "') within group (order by Domain desc) + '"]'
-- from
-- (
--     select
--         ClientAcceptanceCode,
--         Domain
--     from
--         dbo.atbl_DCS_Revisions with (nolock)
--     where
--         ClientAcceptanceCode is not null
--     group by
--         ClientAcceptanceCode,
--         Domain
-- ) T
-- group by
--     ClientAcceptanceCode

select
    ClientAcceptanceCode,
    Domains = (
        select distinct Domain
        from dbo.atbl_DCS_Revisions Domains with (nolock)
        where Domains.ClientAcceptanceCode = Codes.ClientAcceptanceCode
        for json auto
    )
from
    dbo.atbl_DCS_Revisions Codes with (nolock)
where
    ClientAcceptanceCode is not null
group by
    ClientAcceptanceCode
for
    json auto