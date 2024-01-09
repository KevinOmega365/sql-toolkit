select
    CountStar = count(*),
    ProarcFiles.DCS_DocumentID,
    ProarcFiles.DCS_Revision,
    ProarcFiles.DCS_OriginalFileName
from
    dbo.ltbl_Import_MuninAibel_RevisionFiles ProarcFiles with (nolock)
group by
    ProarcFiles.DCS_DocumentID,
    ProarcFiles.DCS_Revision,
    ProarcFiles.DCS_OriginalFileName
having
    count(*) > 1