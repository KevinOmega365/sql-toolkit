select top 5
    activate_link_document =
        '<a href="' +
        'https://pims.akerbp.com/dcs-documents-details?Domain=' +
        Pims.Domain +
        '&DocID=' +
        Pims.DocumentID +
        '">' +
        Pims.DocumentID +
        '</a>',
    Pims.Domain,
    Pims.DocumentID,
    PimsFile.OriginalFilename
from
    dbo.atbl_DCS_Documents Pims with (nolock)
    join dbo.ltbl_Import_DCS_DCS_FileRepairRecords AS FRR WITH (NOLOCK)
        on FRR.DCS_Domain = Pims.Domain
        and FRR.DCS_DocumentID = Pims.DocumentID
    join dbo.atbl_DCS_RevisionsFiles PimsFile with (nolock)
        on PimsFile.PrimKey = FRR.DcsRevFileRef
where
    FRR.INTEGR_REC_STATUS = 'ACTION_UPDATE_FILE'
order by
    newid()