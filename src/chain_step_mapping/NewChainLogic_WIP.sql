select top 50
    PR.ReviewStatus,
    PD.ReviewClass,
    PD.Criticality,
    PR.Step
from
    dbo.ltbl_Import_MuninAibel_Documents as ID with (nolock)
    left join dbo.ltbl_Import_MuninAibel_Revisions as IR with (nolock)
        on IR.DCS_Domain = ID.DCS_Domain
        and IR.DCS_DocumentID = ID.DCS_DocumentID
    left join dbo.atbl_DCS_Documents PD with (nolock)
        on PD.Domain = ID.DCS_Domain
    left join dbo.atbl_DCS_Revisions PR with (nolock)
        on PR.Domain = PD.Domain
        and PR.DocumentID = PD.DocumentID
where
    PD.domain = '175'
order by 
    newid()