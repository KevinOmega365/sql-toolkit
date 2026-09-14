/*
 * vendors - email domains - user counts - missing values
 */
select
    vendor,
    UserCount = sum(VendorDomainCount),
    EmailDomainUserCount = '[ ' + string_agg('[ "' + EmailDomain + '", ' + cast(VendorDomainCount as nvarchar(3)) + ' ]', ', ') + ' ]'
from
(
    select
        VendorDomainCount = count(*),
        vendor,
        EmailDomain
    from
        (
            select
                vendor = isnull(vendor, 'VENDOR_IS_BLANK'),
                EmailDomain = isnull(
                    right(
                        lower(company_email),
                        len(company_email) - charindex('@', company_email) + 1
                    ),
                    'USER_EMAIL_IS_BLANK'
                )
            from
                dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
            -- where
            --     company_email is not null
            --     and vendor is not null
        ) U
    group by
        vendor,
        EmailDomain
) T
group by
    vendor
order by
    vendor

/*
 * distinct vendors
 */
select distinct vendor
from dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
where vendor is not null
order by vendor