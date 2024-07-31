declare
    @groupRef uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @action_update nvarchar(128) = 'ACTION_UPDATE',
    @dateFormat int = 105

/**
 * Per-document changes
 */
select * -- top 50 *
from (
    select
        D.Domain,
        DocumentID = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain=' + D.Domain + '&DocID=' + D.DocumentID + '";"' + D.DocumentID + '")',
        D.Title,
        TitleChange = isnull(I.DCS_Title, 'NULL')
        -- PlantID = case when isnull(D.PlantID, '') <> isnull(I.DCS_PlantID, '') then cast(isnull(D.PlantID, 'NULL') + ' -> ' + isnull(I.DCS_PlantID, 'NULL') as nvarchar(max)) else '' end,
        -- OriginatorCompany = case when isnull(D.OriginatorCompany, '') <> isnull(I.DCS_OriginatorCompany, '') then isnull(D.OriginatorCompany, 'NULL') + ' -> ' + isnull(I.DCS_OriginatorCompany, 'NULL') else '' end,
        -- FacilityID = case when isnull(D.FacilityID, '') <> isnull(I.DCS_FacilityID, '') then isnull(D.FacilityID, 'NULL') + ' -> ' + isnull(I.DCS_FacilityID, 'NULL') else '' end,
        -- DocumentType = case when isnull(D.DocumentType, '') <> isnull(I.DCS_DocumentType, '') then isnull(D.DocumentType, 'NULL') + ' -> ' + isnull(I.DCS_DocumentType, 'NULL') else '' end,
        -- DocumentGroup = case when isnull(D.DocumentGroup, '') <> isnull(I.DCS_DocumentGroup, '') then isnull(D.DocumentGroup, 'NULL') + ' -> ' + isnull(I.DCS_DocumentGroup, 'NULL') else '' end,
        -- Discipline = case when isnull(D.Discipline, '') <> isnull(I.DCS_Discipline, '') then isnull(D.Discipline, 'NULL') + ' -> ' + isnull(I.DCS_Discipline, 'NULL') else '' end,
        -- ContractNo = case when isnull(D.ContractNo, '') <> isnull(I.DCS_ContractNo, '') then isnull(D.ContractNo, 'NULL') + ' -> ' + isnull(I.DCS_ContractNo, 'NULL') else '' end,
        -- Criticality = case when isnull(D.Criticality, '') <> isnull(I.DCS_Criticality, '') then isnull(D.Criticality, 'NULL') + ' -> ' + isnull(I.DCS_Criticality, 'NULL') else '' end,
        -- Area = case when isnull(D.Area, '') <> isnull(I.DCS_Area, '') then isnull(D.Area, 'NULL') + ' -> ' + isnull(I.DCS_Area, 'NULL') else '' end,
        -- Confidential = case when D.Confidential <> I.DCS_Confidential then case when D.Confidential = 1 then 'true' else 'false' end + ' -> ' + case when I.DCS_Confidential = 1 then 'true' else 'false' end else '' end,
        -- Classification = case when isnull(D.Classification, '') <> isnull(I.DCS_Classification, '') then isnull(D.Classification, 'NULL') + ' -> ' + isnull(I.DCS_Classification, 'NULL') else '' end,
        -- PONumber = case when isnull(D.PONumber, '') <> isnull(I.DCS_PONumber, '') then isnull(D.PONumber, 'NULL') + ' -> ' + isnull(I.DCS_PONumber, 'NULL') else '' end
        -- System = case when isnull(D.System, '') <> isnull(I.DCS_System, '') then isnull(D.System, 'NULL') + ' -> ' + isnull(I.DCS_System, 'NULL') else '' end,
        -- VoidedDate = case when isnull(D.VoidedDate, '') <> isnull(I.DCS_VoidedDate, '') then isnull(convert(nvarchar, D.VoidedDate, @dateFormat), 'NULL') + ' -> ' + isnull(convert(nvarchar, I.DCS_VoidedDate, @dateFormat), 'NULL') else '' end
        -- ReviewClass = case when isnull(D.ReviewClass, '') <> isnull(I.DCS_ReviewClass, '') then isnull(D.ReviewClass, 'NULL') + ' -> ' + isnull(I.DCS_ReviewClass, 'NULL') else '' end
    from
        dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
        join dbo.atbl_DCS_Documents D with (nolock)
            on D.Domain = I.DCS_Domain
            and D.DocumentID = I.DCS_DocumentID
    where
        INTEGR_REC_STATUS = @action_update
        and INTEGR_REC_GROUPREF = @groupRef
        and (
isnull(D.Title, '') <> isnull(I.DCS_Title, '')
-- isnull(D.PlantID, '') <> isnull(I.DCS_PlantID, '')
-- isnull(D.OriginatorCompany, '') <> isnull(I.DCS_OriginatorCompany, '')
-- isnull(D.FacilityID, '') <> isnull(I.DCS_FacilityID, '')
-- isnull(D.DocumentType, '') <> isnull(I.DCS_DocumentType, '')
-- isnull(D.DocumentGroup, '') <> isnull(I.DCS_DocumentGroup, '')
-- isnull(D.Discipline, '') <> isnull(I.DCS_Discipline, '')
-- isnull(D.ContractNo, '') <> isnull(I.DCS_ContractNo, '')
-- isnull(D.Criticality, '') <> isnull(I.DCS_Criticality, '')
-- isnull(D.Area, '') <> isnull(I.DCS_Area, '')
-- or D.Confidential <> I.DCS_Confidential
-- or isnull(D.Classification, '') <> isnull(I.DCS_Classification, '')
-- or isnull(D.PONumber, '') <> isnull(I.DCS_PONumber, '')
-- isnull(D.System, '') <> isnull(I.DCS_System, '')
-- isnull(D.VoidedDate, '') <> isnull(I.DCS_VoidedDate, '')
-- isnull(D.ReviewClass, '') <> isnull(I.DCS_ReviewClass, '')
        )
) T
order by
    Domain,
    DocumentID