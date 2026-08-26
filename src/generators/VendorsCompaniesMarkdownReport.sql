/*
 * Markdown Report: Vendors - Companies
 *   vendors - email domains - user counts - missing values
 */
 
declare @AllowOnlyCleanData bit = 0

declare @crlf nchar(2) = CHAR(13)+CHAR(10)
declare @MarkdownTableHeader nvarchar(max) = '| Vendor | User Count | Email domain: User Count |' + @crlf + '| --- | --- | --- |'
declare @MarkdownTitleAndDescription nvarchar(max) = '# Vendors - Companies' + @crlf + @crlf + 'vendors - email domains - user counts - missing values'

select
    MarkdownReport =
        @MarkdownTitleAndDescription + @crlf + @crlf +
        @MarkdownTableHeader + @crlf +
        string_agg(MarkdownTableRow, @crlf) + @crlf
from
    (
        select
            MarkdownTableRow = '| ' + vendor + ' | ' + cast(UserCount as nvarchar(3)) + ' | ' + EmailDomainUserCountMarkdown + ' |'
        from
            (
                select
                    vendor,
                    UserCount = sum(VendorDomainCount),
                    EmailDomainUserCountMarkdown = string_agg(EmailDomain + ': ' + cast(VendorDomainCount as nvarchar(3)), '<br>')
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
                                where
                                    @AllowOnlyCleanData = 0
                                    or
                                    company_email is not null
                                    and vendor is not null
                            ) U
                        group by
                            vendor,
                            EmailDomain
                    ) T
                group by
                    vendor
            ) U
    ) V

/*
 * distinct vendors
 */
select distinct vendor
from dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
where vendor is not null
order by vendor
