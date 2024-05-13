declare
    @groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @action_update nvarchar(128) = 'ACTION_UPDATE',
    @dateFormat int = 105

/**
 * Per-document changes
 */
select
    D.Domain,
    D.DocumentID,
    D.Title,
    TitleChange = case when isnull(D.Title, '') <> isnull(I.DCS_Title, '') then isnull(D.Title, 'NULL') + ' -> ' + isnull(I.DCS_Title, 'NULL') else '' end,
    PlantID = case when isnull(D.PlantID, '') <> isnull(I.DCS_PlantID, '') then isnull(D.PlantID, 'NULL') + ' -> ' + isnull(I.DCS_PlantID, 'NULL') else '' end,
    OriginatorCompany = case when isnull(D.OriginatorCompany, '') <> isnull(I.DCS_OriginatorCompany, '') then isnull(D.OriginatorCompany, 'NULL') + ' -> ' + isnull(I.DCS_OriginatorCompany, 'NULL') else '' end,
    FacilityID = case when isnull(D.FacilityID, '') <> isnull(I.DCS_FacilityID, '') then isnull(D.FacilityID, 'NULL') + ' -> ' + isnull(I.DCS_FacilityID, 'NULL') else '' end,
    DocumentType = case when isnull(D.DocumentType, '') <> isnull(I.DCS_DocumentType, '') then isnull(D.DocumentType, 'NULL') + ' -> ' + isnull(I.DCS_DocumentType, 'NULL') else '' end,
    DocumentGroup = case when isnull(D.DocumentGroup, '') <> isnull(I.DCS_DocumentGroup, '') then isnull(D.DocumentGroup, 'NULL') + ' -> ' + isnull(I.DCS_DocumentGroup, 'NULL') else '' end,
    Discipline = case when isnull(D.Discipline, '') <> isnull(I.DCS_Discipline, '') then isnull(D.Discipline, 'NULL') + ' -> ' + isnull(I.DCS_Discipline, 'NULL') else '' end,
    ContractNo = case when isnull(D.ContractNo, '') <> isnull(I.DCS_ContractNo, '') then isnull(D.ContractNo, 'NULL') + ' -> ' + isnull(I.DCS_ContractNo, 'NULL') else '' end,
    Criticality = case when isnull(D.Criticality, '') <> isnull(I.DCS_Criticality, '') then isnull(D.Criticality, 'NULL') + ' -> ' + isnull(I.DCS_Criticality, 'NULL') else '' end,
    Area = case when isnull(D.Area, '') <> isnull(I.DCS_Area, '') then isnull(D.Area, 'NULL') + ' -> ' + isnull(I.DCS_Area, 'NULL') else '' end,
    Confidential = case when D.Confidential <> I.DCS_Confidential then case when D.Confidential = 1 then 'true' else 'false' end + ' -> ' + case when I.DCS_Confidential = 1 then 'true' else 'false' end else '' end,
    Classification = case when isnull(D.Classification, '') <> isnull(I.DCS_Classification, '') then isnull(D.Classification, 'NULL') + ' -> ' + isnull(I.DCS_Classification, 'NULL') else '' end,
    PONumber = case when isnull(D.PONumber, '') <> isnull(I.DCS_PONumber, '') then isnull(D.PONumber, 'NULL') + ' -> ' + isnull(I.DCS_PONumber, 'NULL') else '' end,
    System = case when isnull(D.System, '') <> isnull(I.DCS_System, '') then isnull(D.System, 'NULL') + ' -> ' + isnull(I.DCS_System, 'NULL') else '' end,
    VoidedDate = case when isnull(D.VoidedDate, '') <> isnull(I.DCS_VoidedDate, '') then isnull(convert(nvarchar, D.VoidedDate, @dateFormat), 'NULL') + ' -> ' + isnull(convert(nvarchar, I.DCS_VoidedDate, @dateFormat), 'NULL') else '' end,
    ReviewClass = case when isnull(D.ReviewClass, '') <> isnull(I.DCS_ReviewClass, '') then isnull(D.ReviewClass, 'NULL') + ' -> ' + isnull(I.DCS_ReviewClass, 'NULL') else '' end
from
    dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = I.DCS_Domain
        and D.DocumentID = I.DCS_DocumentID
where
    INTEGR_REC_STATUS = @action_update
    and INTEGR_REC_GROUPREF = @groupRef
order by
    D.Domain,
    D.DocumentID