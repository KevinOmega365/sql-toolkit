-- execute as login = 'af_Integrations_ServiceUser'
-- select suser_sname()

select
    DCS_Domain,
    ImportIsNull = sum(ImportIsNull),
    PimsIsNull = sum(PimsIsNull),
    Count = sum(Count)
from
    (
        select
            DCS_Domain,
            ImportIsNull = case when ImpR.DCS_ContractorSupplierAcceptanceCode is null then 1 else 0 end,
            PimsIsNull = case when DcsR.ContractorSupplierAcceptanceCode is null then 1 else 0 end,
            Count = 1
        from 
            dbo.ltbl_Import_DTS_DCS_Revisions AS ImpR WITH (NOLOCK)
            join dbo.atbl_DCS_Revisions DcsR with (nolock)
                on DcsR.Domain = ImpR.DCS_Domain
                and DcsR.DocumentID = ImpR.DCS_DocumentID
                and DcsR.Revision = ImpR.DCS_Revision
        where
            isnull(ImpR.DCS_ContractorSupplierAcceptanceCode, '') <> isnull(DcsR.ContractorSupplierAcceptanceCode, '')
    ) T
group by
    DCS_Domain


-- select
--     DCS_Domain,
--     count(*)
-- from 
--     dbo.ltbl_Import_DTS_DCS_Revisions AS ImpR WITH (NOLOCK)
--     join dbo.atbl_DCS_Revisions DcsR with (nolock)
--         on DcsR.Domain = ImpR.DCS_Domain
--         and DcsR.DocumentID = ImpR.DCS_DocumentID
--         and DcsR.Revision = ImpR.DCS_Revision
-- where
--     isnull(ImpR.DCS_ContractorSupplierAcceptanceCode, '') <> isnull(DcsR.ContractorSupplierAcceptanceCode, '')
-- group by
--     DCS_Domain
