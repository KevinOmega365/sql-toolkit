select
    Instances = count(*),
    Pipeline = (select Name from dbo.atbl_Integrations_ScheduledTasksConfigGroups as P with (nolock) where PrimKey = D.INTEGR_REC_GROUPREF),
    Domain = DCS_Domain,
    PlantNo = (select PlantNo from dbo.atbl_Asset_Plants P with (nolock) where P.PlantID = D.DCS_PlantID),
    PlantID = DCS_PlantID,
    FacilityID = DCS_FacilityID,
    Area = DCS_Area,
    HasConfig = case
        when
            (
                select Primkey
                from dbo.atbl_Asset_FacilitiesAreas FA with (nolock)
                where
                    FA.Area = D.DCS_Area
                    and FA.FacilityID = D.DCS_FacilityID
                    and FA.PlantID = D.DCS_PlantID
            ) is null
        then 'nope'
        else 'yupp'
    end
from
    dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
where
    D.INTEGR_REC_GROUPREF = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
group by
    INTEGR_REC_GROUPREF,
    DCS_Domain,
    DCS_PlantID,
    DCS_FacilityID,
    DCS_Area
order by
    INTEGR_REC_GROUPREF,
    DCS_Domain,
    DCS_PlantID,
    DCS_FacilityID,
    DCS_Area