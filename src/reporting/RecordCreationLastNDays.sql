
declare @lastNumberOfDays int = 100

-------------------------------------------------------------------------------

declare @startDate date =
    cast(
        dateadd(
            day,
            - @lastNumberOfDays,
            getDate()
        ) 
    as date)

-------------------------------------------------------------------------------

declare @DomainRange table (
    Domain nvarchar(128)
)
insert into @DomainRange
values
    ('128'),
    ('148'),
    ('187')

-------------------------------------------------------------------------------

declare @DateRows table
(
    DateBucket date
)
insert into @DateRows
select
    cast(dateadd(day, - N, getDate()) as date)
from
(
    select top (@lastNumberOfDays)
        N = row_number() over(order by object_id) - 1
    from
        sys.objects
) T

-------------------------------------------------------------------------------

declare @DocumentsPerDay table
(
    CreatedDate date,
    RecordCount int
)
insert into @DocumentsPerDay
select
    CreatedDate,
    RecordCount = count(*)
from
(
    select CreatedDate = cast(Created as date)
    from dbo.atbl_DCS_Documents with (nolock)
    where
        domain in (select Domain from @DomainRange)
        and CreatedBy = 'af_Integrations_ServiceUser'
        and Created > @startDate
) T
group by
    CreatedDate

-------------------------------------------------------------------------------

declare @RevisionsPerDay table
(
    CreatedDate date,
    RecordCount int
)
insert into @RevisionsPerDay
select
    CreatedDate,
    RecordCount = count(*)
from
(
    select CreatedDate = cast(Created as date)
    from dbo.atbl_DCS_Revisions with (nolock)
    where
        domain in (select Domain from @DomainRange)
        and CreatedBy = 'af_Integrations_ServiceUser'
        and Created > @startDate
) T
group by
    CreatedDate

-------------------------------------------------------------------------------

declare @FilesPerDay table
(
    CreatedDate date,
    RecordCount int
)
insert into @FilesPerDay
select
    CreatedDate,
    RecordCount = count(*)
from
(
    select CreatedDate = cast(Created as date)
    from dbo.atbl_DCS_RevisionsFiles with (nolock)
    where
        domain in (select Domain from @DomainRange)
        and CreatedBy = 'af_Integrations_ServiceUser'
        and Created > @startDate
) T
group by
    CreatedDate

-------------------------------------------------------------------------------

select
    ImportDate = DateBucket,
    Documents = isnull((select RecordCount from @DocumentsPerDay where CreatedDate = DateBucket), 0),
    Revisions = isnull((select RecordCount from @RevisionsPerDay where CreatedDate = DateBucket), 0),
    Files = isnull((select RecordCount from @FilesPerDay where CreatedDate = DateBucket), 0)
from
    @DateRows
order by
    DateBucket desc
