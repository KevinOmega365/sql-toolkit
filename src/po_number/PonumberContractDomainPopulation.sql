
----------------------------------------------------- ContractNo Mapping --
-- declare @ContractNoMapping table (
--     Domain nvarchar(128),
--     FacilityCodeKey nvarchar(max),
--     OriginatorKey nvarchar(max),
--     ContractNoValue nvarchar(64),
--     MatchingPriority int,
--     Description nvarchar(512)
-- )
-- insert into @ContractNoMapping
-- values
--     -- Yggdrasil
--     ('187', 'FRO', '%', 'C-02145', 1, 'ContractNo based on Domain and FacilityCode'), -- WFL-171972
--     ('128', 'FPQ', '%', 'C-02146', 1, 'ContractNo based on Domain and FacilityCode'),
--     ('128', 'FUI', '%', 'C-02146', 1, 'ContractNo based on Domain and FacilityCode'),
--     ('128', 'IOC', '%', 'C-02146', 1, 'ContractNo based on Domain and FacilityCode'),
--     ('128', 'AAR', '%', 'C-02146', 1, 'ContractNo based on Domain and FacilityCode'), -- WFL-170657
--     ('128', 'BOR', '%', 'C-02146', 1, 'ContractNo based on Domain and FacilityCode'), -- WFL-170657
--     -- PWP-Fenris
--     ('153', '%', '%', 'C-01990', 1, 'ContractNo based on Domain'),
--     ('145', '%', '%', 'C-01989', 1, 'ContractNo based on Domain')

SELECT DISTINCT
    Domain = DCS_Domain,
    ContractNo = DCS_ContractNo,
    PONumber = DCS_PONumber
    -- ,facility_code
    -- ,originator
    -- ,INTEGR_REC_STATUS
FROM
    [dbo].[ltbl_Import_ProArc_Documents] AS D WITH (NOLOCK)
WHERE
    DCS_Domain IS NOT NULL
    AND DCS_PONumber IS NOT NULL
    --AND INTEGR_REC_STATUS NOT IN ('OUT_OF_SCOPE')

and DCS_ContractNo is not null

order by
    Domain,
    ContractNo,
    PONumber