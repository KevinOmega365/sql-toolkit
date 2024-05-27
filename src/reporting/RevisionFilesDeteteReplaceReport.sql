/**
 * Use exported JSON list to confirm deletion and replacement
 * 
 */

declare @DocumentsToReplaceJson nvarchar(max) = '[
    {
        "Domain": "Azul",
        "DocumentID": "ABC-ET1337-XD-24816-01",
        "Revision": "X19",
        "OriginalFilename": "ABC-ET1337-XD-24816-01_03_1.PDF",
        "Primkey": "2C875106-521C-4387-B2AF-74AF969938A6"
    }
]'


/**
 * The DELETE
 */
-- select *
-- from
--     dbo.atbl_DCS_RevisionsFiles as PRF with (nolock)
-- where
--     Primkey in
--     (
--         select
--             -- Domain = json_value(value, '$.Domain'),
--             -- DocumentID = json_value(value, '$.DocumentID'),
--             -- Revision = json_value(value, '$.Revision'),
--             -- OriginalFilename = json_value(value, '$.OriginalFilename'),
--             Primkey = json_value(value, '$.Primkey')
--         from
--             openjson(@DocumentsToReplaceJson)
--     )

/**
 * The Report
 */
select
    -- ImportPrimKey = IRF.PrimKey,
    T.Domain,
    T.DocumentID,
    PimsLink = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";B2;"&DocID=";C2);"Open in Pims")',
    T.Revision,
    T.OriginalFilename
    -- T.Primkey,
    -- ImortFileSize = IRF.DCS_FileSize,
    -- PimsFileSize = PRF.FileSize
from
(select
    Domain = json_value(value, '$.Domain'),
    DocumentID = json_value(value, '$.DocumentID'),
    Revision = json_value(value, '$.Revision'),
    OriginalFilename = json_value(value, '$.OriginalFilename'),
    Primkey = json_value(value, '$.Primkey')
from
    openjson(@DocumentsToReplaceJson)) T
    left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles as IRF with (nolock)
        on IRF.DCS_Domain = T.Domain
        and IRF.DCS_DocumentID = T.DocumentID
        and IRF.DCS_Revision = T.Revision
        and IRF.DCS_OriginalFilename = T.OriginalFilename
    left join dbo.atbl_DCS_Revisions as PR with (nolock)
        on PR.Domain = T.Domain
        and PR.DocumentID = T.DocumentID
        and PR.Revision = T.Revision
    left join dbo.atbl_DCS_RevisionsFiles as PRF with (nolock)
        on PRF.Domain = PR.Domain
        and PRF.DocumentID = PR.DocumentID
        and PRF.RevisionItemNo = PR.RevisionItemNo
        and PRF.OriginalFilename = T.OriginalFilename