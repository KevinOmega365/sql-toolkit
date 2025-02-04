/*
 * List out the pipelines with large file counts
 */
SELECT
    Pipline = (
        select name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups with (nolock)
        where PrimKey = RevisionsFiles.INTEGR_REC_GROUPREF),
    RevisionsFiles.INTEGR_REC_GROUPREF,
    Count =  COUNT(*)
FROM
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RevisionsFiles WITH (NOLOCK)
    LEFT JOIN dbo.ltbl_Import_DTS_DCS_Files AS Files WITH (NOLOCK)
        ON Files.object_guid = RevisionsFiles.object_guid
WHERE
    Files.PrimKey IS NULL

    -- todo: remove this
    AND len(RevisionsFiles.fileSize) > 8 -- exclude really big files temporarily

GROUP BY
    RevisionsFiles.INTEGR_REC_GROUPREF
