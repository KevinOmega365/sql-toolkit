
select distinct
    DomainsPlants.Domain
    , DomainName = (
        select Name
        from dbo.stbl_System_Domains Domains with (nolock)
        where Domains.Domain = DomainsPlants.Domain
    )
    -- , SubSystems.PlantID
    -- , SubSystems.System
    -- , SubSystems.SubSystem
from
    dbo.atbl_Asset_SubSystems AS SubSystems WITH (NOLOCK)
    INNER JOIN dbo.atbl_DCS_DomainsPlants AS DomainsPlants WITH (NOLOCK)
        ON DomainsPlants.PlantID = SubSystems.PlantID
WHERE
    not (
            len(System) <> 2
        or
            len(System) = 2
            and left(SubSystem, 2) <> System
    )
order BY
    DomainsPlants.Domain

select distinct
    ImportDocuments.DCS_Domain,
    ImportDocuments.DCS_PlantID,
    ImportDocuments.DCS_System,
    SubSystems.PlantID,
    SubSystems.System,
    SubSystems.SubSystem,
    SubSystems.Description
from
    dbo.ltbl_Import_DTS_DCS_Documents ImportDocuments with (nolock)
    left join dbo.atbl_Asset_SubSystems AS SubSystems WITH (NOLOCK)
        on SubSystems.PlantID = ImportDocuments.DCS_PlantID
        and SubSystems.SubSystem = ImportDocuments.DCS_System
where
    ImportDocuments.INTEGR_REC_ERROR like '%FAILED%FOREIGN KEY constraint%dbo.atbl_Asset_Systems%'
