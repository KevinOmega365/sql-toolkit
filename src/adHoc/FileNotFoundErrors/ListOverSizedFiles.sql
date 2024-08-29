SELECT
    RevisionFileRef = RevisionsFiles.PrimKey
    Domain = DCS_Domain,
    Revision = DCS_Revision,
    RevisionsFiles.originalFilename
    RevisionsFiles.fileSize
FROM
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RevisionsFiles WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Files AS Files WITH (NOLOCK)
        ON Files.object_guid = RevisionsFiles.object_guid
WHERE
    Files.PrimKey IS NULL
    AND len(RevisionsFiles.fileSize) > 9
