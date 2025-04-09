-- select top 1 *
-- from dbo.atbl_DCS_Documents D with (nolock)
-- where
--     Domain = '128'
--     and CurrentStep like '%R'

select
    D.PrimKey,
    D.Domain,
    D.DocumentID,
    I.Distribution
from
    dbo.atbl_DCS_Documents D with (nolock)
    join (
        select
            DCS_Domain,
            DCS_DocumentID,
            Distribution = '["' + string_agg(json_value(Dist.value, '$.value'), '"", "') + '"]'
        from
            dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
            cross apply openjson(JsonRow, '$.otherCompanyDistributions') Dist
        where
            JsonRow like '%otherCompanyDistributions%'
            and json_value(Dist.value, '$.value') like '%R'
        group by
            DCS_Domain,
            DCS_DocumentID
        having
            count(*) > 1
    ) I
        on I.DCS_Domain = D.Domain
        and I.DCS_DocumentID = D.DocumentID