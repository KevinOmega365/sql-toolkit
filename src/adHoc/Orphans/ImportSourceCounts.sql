declare @domain nvarchar(128) = '145'

select left(Import_ExternalUniqueRef, charindex(':', Import_ExternalUniqueRef) -1), Count = count(*)
from
    dbo.atbl_DCS_RevisionsFiles P with (nolock)
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
        on P.Import_ExternalUniqueRef = I.DCS_Import_ExternalUniqueRef
where
    P.Domain = @domain
    and P.CreatedBy = 'af_Integrations_ServiceUser'
    and I.PrimKey is null
group by
    left(Import_ExternalUniqueRef, charindex(':', Import_ExternalUniqueRef) -1)