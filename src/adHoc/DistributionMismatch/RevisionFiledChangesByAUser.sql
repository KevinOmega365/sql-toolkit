declare @fields nvarchar(max) = '["IsIssuedForReview","ReviewDeadline"]' -- 'IsIssuedForReview' -- '%' --
declare @username nvarchar(128) = 'a_tif_hans'

select
    CreatedDate,
    CreatedHour,
    CreatedMinute,
    ChangeCount = count(*),
    Domains = (
        select
            string_agg(Domain, ', ')
        from (
            select distinct Domain
            from [dbo].[atbl_DCS_RevisionsLog] RL with (nolock)
            where
                RL.CreatedBy = @username
                and (
                    isjson(@fields) = 1
                    and RL.FieldName in (select value from openjson(@fields))
                    or RL.FieldName like @fields
                )
                and cast(RL.Created as date) = T.CreatedDate
                and datepart(hour, RL.Created) = T.CreatedHour
                and datepart(minute, RL.Created) = T.CreatedMinute
        ) U
    ),
    DocumentIDs = (
        select
            string_agg(DocumentID, ', ')
        from (
            select
                distinct DocumentID
            from
                [dbo].[atbl_DCS_RevisionsLog] RL with (nolock)
            where
                RL.CreatedBy = @username
                and (
                    isjson(@fields) = 1
                    and RL.FieldName in (select value from openjson(@fields))
                    or RL.FieldName like @fields
                )
                and cast(RL.Created as date) = T.CreatedDate
                and datepart(hour, RL.Created) = T.CreatedHour
                and datepart(minute, RL.Created) = T.CreatedMinute
        ) V
    ),
    FieldNames = (
        select
            string_agg(FieldName, ', ')
        from (
            select
                distinct FieldName
            from
                [dbo].[atbl_DCS_RevisionsLog] RL with (nolock)
            where
                RL.CreatedBy = @username
                and (
                    isjson(@fields) = 1
                    and RL.FieldName in (select value from openjson(@fields))
                    or RL.FieldName like @fields
                )
                and cast(RL.Created as date) = T.CreatedDate
                and datepart(hour, RL.Created) = T.CreatedHour
                and datepart(minute, RL.Created) = T.CreatedMinute
        ) W
    )
from
(
    select
        CreatedDate = cast(Created as date),
        CreatedHour = datepart(hour, Created),
        CreatedMinute = datepart(minute, Created),
        Domain,
        DocumentID,
        FieldName
    from
        [dbo].[atbl_DCS_RevisionsLog] with (nolock)
    where
        CreatedBy = @username
        and (
            isjson(@fields) = 1
            and FieldName in (select value from openjson(@fields))
            or FieldName like @fields
        )
) T
group by
    CreatedDate,
    CreatedHour,
    CreatedMinute
order by
    CreatedDate desc,
    CreatedHour desc,
    CreatedMinute desc
