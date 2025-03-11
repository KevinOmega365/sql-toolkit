
update frr set DcsRevFileRef = P_RF.PrimKey
from
    dbo.atbl_DCS_RevisionsFiles P_RF with (nolock)
    JOIN dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
        on P_RF.Import_ExternalUniqueRef like 'DTS:' + cast(FRR.object_guid as nchar(36))
where
    P_RF.Domain in ('128', '187')