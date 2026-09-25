
declare @ShowAll bit = 0
declare @n int = 2 -- number of pattern segments

/*
 * finding companies vendors
 */
select
    SqlValue = '(''' + vendor + ''', ''' + GuessCompanyID + ''', ''' + GuessName + '''),',
    vendor,
    GuessCompanyID,
    GuessName,
    PatternToo,
    CountToo,
    ListToo,
    VendorPattern,
    MatchCount,
    MatchList
from
(
    select
        U.vendor
        , GuessCompanyID =
            case
                when MatchCount = 1
                    then (
                        select C.CompanyID
                        from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                        where
                            C.IsApproved = 1
                            and C.Name like U.VendorPattern
                    )
                when CountToo = 1
                    then (
                        select C.CompanyID
                        from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                        where
                            C.IsApproved = 1
                            and C.Name like U.PatternToo
                    )
            end
            , GuessName =
            case
                when MatchCount = 1
                    then (
                        select C.Name
                        from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                        where
                            C.IsApproved = 1
                            and C.Name like U.VendorPattern
                    )
                when CountToo = 1
                    then (
                        select C.Name
                        from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                        where
                            C.IsApproved = 1
                            and C.Name like U.PatternToo
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
                CountToo = (
                    select count(*)
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where
                        C.IsApproved = 1
                        and C.Name like T.PatternToo
                ),
                ListToo = (
                    select '[ ' + string_agg('"' + C.Name + '"', ', ') + ' ]'
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where
                        C.IsApproved = 1
                        and C.Name like T.PatternToo
                ),
                T.VendorPattern,
                MatchCount = (
                    select count(*)
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock) where
                        C.IsApproved = 1
                        and C.Name
                    like T.VendorPattern
                ),
                MatchList = (
                    select '[ ' + string_agg('"' + C.Name + '"', ', ') + ' ]'
                    from dbo.atbl_ProjectSetup_Companies as C with (nolock)
                    where
                        C.IsApproved = 1
                        and C.Name like T.VendorPattern
                )
            from
                (
                    select
                        distinct vendor,
                        VendorPattern = left(vendor, charindex(' ', vendor) - 1) + '%',
                        PatternToo = (
                            select string_agg(value, '%')
                            from (
                                select top (@n) value from string_split(vendor, ' ')
                                ) Q
                        ) + '%'
                    from
                        dbo.ltbl_Import_TIF_PersonsPositions as I with (nolock)
                    where
                        vendor is not null
                ) T
        ) U
    ) V
where (
    @ShowAll = 1
    or (
        MatchCount = 1
        or CountToo = 1
    )
)
order by
    vendor
