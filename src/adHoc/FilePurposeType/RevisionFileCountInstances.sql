
declare @DomainPattern  nvarchar(max) = '127' -- '%'
declare @FilePurposeTypePattern nvarchar(max) = '%' -- 'original'

declare @TotalRevisions int = (
    select
        count(*)
    from
    (
        select
            RevisionItem = 1
        from
            dbo.atbl_DCS_RevisionsFiles with (nolock)
        where
            Domain like @DomainPattern
            and Type like @FilePurposeTypePattern
        group by
            Domain,
            DocumentID,
            RevisionItemNo
    ) T
)

/*
 * Counting files per revision
 */
select
    FileCount,
    Instances = count(*),
    Percentage = format(count(*) / (@TotalRevisions * 1.0), 'P4')
from
(
    select
        FileCount = count(*)
    from
        dbo.atbl_DCS_RevisionsFiles with (nolock)
    where
        Domain like @DomainPattern
    group by
        Domain,
        DocumentID,
        RevisionItemNo
) T
group by
    FileCount
order by
    FileCount

select RevisionCount = @TotalRevisions
