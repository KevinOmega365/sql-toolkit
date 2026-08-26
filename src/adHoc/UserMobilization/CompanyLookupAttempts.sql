
declare @n int = 2 -- number of pattern segments

/*
 * finding companies vendors
 */
 select
    U.vendor
    , GuessCompanyID =
        case
            when MatchCount = 1
                then (
                    select C.CompanyID
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where C.Name like U.VendorPattern
                )
            when CountToo = 1
                then (
                    select C.CompanyID
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where C.Name like U.PatternToo
                )
        end
        , GuessName =
        case
            when MatchCount = 1
                then (
                    select C.Name
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where C.Name like U.VendorPattern
                )
            when CountToo = 1
                then (
                    select C.Name
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where C.Name like U.PatternToo
                )
        end
    , U.PatternToo
    , U.CountToo
    , U.ListToo
    , U.VendorPattern
    , U.MatchCount
    , U.MatchList
from
    (
        select
            T.vendor,
            T.PatternToo,
            CountToo = (select count(*) from dbo.atbl_ProjectSetup_Companies as C with (nolock) where C.Name like T.PatternToo),
            ListToo = (select '[ ' + string_agg('"' + C.Name + '"', ', ') + ' ]' from dbo.atbl_ProjectSetup_Companies as C with (nolock) where C.Name like T.PatternToo),
            T.VendorPattern,
            MatchCount = (select count(*) from dbo.atbl_ProjectSetup_Companies as C with (nolock) where C.Name like T.VendorPattern),
            MatchList = (select '[ ' + string_agg('"' + C.Name + '"', ', ') + ' ]' from dbo.atbl_ProjectSetup_Companies as C with (nolock) where C.Name like T.VendorPattern)
        from
            (
                select
                    distinct vendor,
                    VendorPattern = left(vendor, charindex(' ', vendor) - 1) + '%',
                    PatternToo = (select string_agg(value, '%') from (select top (@n) value from string_split(vendor, ' ')  ) Q) + '%'
                from
                    dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
                where
                    vendor is not null
            ) T
    ) U
order by
    U.vendor

/*
 * distinct vendors
 */
-- select distinct vendor
-- from dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
-- where vendor is not null
-- order by vendor

/*
 * vendors - email domains - user counts - missing values
 */
-- select
--     vendor,
--     UserCount = sum(VendorDomainCount),
--     EmailDomainUserCount = '[ ' + string_agg('[ "' + EmailDomain + '", ' + cast(VendorDomainCount as nvarchar(3)) + ' ]', ', ') + ' ]'
-- from
-- (
--     select
--         VendorDomainCount = count(*),
--         vendor,
--         EmailDomain
--     from
--         (
--             select
--                 vendor = isnull(vendor, 'VENDOR_IS_BLANK'),
--                 EmailDomain = isnull(
--                     right(
--                         lower(company_email),
--                         len(company_email) - charindex('@', company_email) + 1
--                     ),
--                     'USER_EMAIL_IS_BLANK'
--                 )
--             from
--                 dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
--             -- where
--             --     company_email is not null
--             --     and vendor is not null
--         ) U
--     group by
--         vendor,
--         EmailDomain
-- ) T
-- group by
--     vendor
-- order by
--     vendor