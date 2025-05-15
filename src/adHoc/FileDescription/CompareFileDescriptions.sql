    ---------------------------------------------------------------------------
    select
        Pipeline = (
            select name
            from dbo.atbl_Integrations_ScheduledTasksConfigGroups AS stcg WITH (NOLOCK)
            where stcg.PrimKey = I.INTEGR_REC_GROUPREF
        ),
        I.DCS_DocumentID,
        I.DCS_Domain,
        I.DCS_OriginalFileName,
        I.DCS_Revision,
        I.DCS_Type,
        I.fileComment,
        I.DCS_FileDescription,
        RF.FileDescription,
        I.INTEGR_REC_STATUS
    FROM
        dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
        INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
            ON F.object_guid = I.object_guid
        INNER JOIN dbo.stbl_System_Files AS F_Sys WITH (NOLOCK)
            ON F_Sys.PrimKey = F.FileRef
        INNER JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
            ON R.Domain = I.DCS_Domain
            AND R.DocumentID = I.DCS_DocumentID
            AND R.Revision = I.DCS_Revision
        INNER JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
            ON RF.Domain = R.Domain
            AND RF.DocumentID = R.DocumentID
            AND RF.RevisionItemNo = R.RevisionItemNo
        INNER JOIN dbo.stbl_System_Files RF_Sys WITH(NOLOCK)
            ON RF_Sys.PrimKey = RF.FileRef
    WHERE
        (
            RF_Sys.PrimKey = F_Sys.PrimKey -- DCS_FileRef is not set on revisions-files yet
            OR RF_Sys.CRC = F_Sys.CRC -- Both CRC and FileRef are used to match "identity" on files
        )
        AND (
            ISNULL(I.DCS_Type, '') <> ISNULL(RF.[Type],'')
            OR ISNULL(I.DCS_FileDescription, '') <> ISNULL(RF.[FileDescription],'')
        )
        AND RF.CreatedBy = 'af_Integrations_ServiceUser'
        -- AND I.INTEGR_REC_BATCHREF = @BatchRef
        -- AND I.INTEGR_REC_STATUS IN (@VALIDATED_OK, @NO_CHANGE)
        AND I.INTEGR_REC_STATUS = 'UPDATED'

/*
 * count by pipleline by status
 */
    -- select
    --     Pipeline = (
    --         select name
    --         from dbo.atbl_Integrations_ScheduledTasksConfigGroups AS stcg WITH (NOLOCK)
    --         where stcg.PrimKey = I.INTEGR_REC_GROUPREF
    --     ),
    --     I.INTEGR_REC_STATUS,
    --     Count = count(*)
    -- FROM
    --     dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
    --     INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
    --         ON F.object_guid = I.object_guid
    --     INNER JOIN dbo.stbl_System_Files AS F_Sys WITH (NOLOCK)
    --         ON F_Sys.PrimKey = F.FileRef
    --     INNER JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
    --         ON R.Domain = I.DCS_Domain
    --         AND R.DocumentID = I.DCS_DocumentID
    --         AND R.Revision = I.DCS_Revision
    --     INNER JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
    --         ON RF.Domain = R.Domain
    --         AND RF.DocumentID = R.DocumentID
    --         AND RF.RevisionItemNo = R.RevisionItemNo
    --     INNER JOIN dbo.stbl_System_Files RF_Sys WITH(NOLOCK)
    --         ON RF_Sys.PrimKey = RF.FileRef
    -- WHERE
    --     (
    --         RF_Sys.PrimKey = F_Sys.PrimKey -- DCS_FileRef is not set on revisions-files yet
    --         OR RF_Sys.CRC = F_Sys.CRC -- Both CRC and FileRef are used to match "identity" on files
    --     )
    --     AND (
    --         ISNULL(I.DCS_Type, '') <> ISNULL(RF.[Type],'')
    --         OR ISNULL(I.DCS_FileDescription, '') <> ISNULL(RF.[FileDescription],'')
    --     )
    --     AND RF.CreatedBy = 'af_Integrations_ServiceUser'
    --     -- AND I.INTEGR_REC_BATCHREF = @BatchRef
    --     -- AND I.INTEGR_REC_STATUS IN (@VALIDATED_OK, @NO_CHANGE)
    -- group by
    --     I.INTEGR_REC_GROUPREF,
    --     I.INTEGR_REC_STATUS
    -- order by
    --     I.INTEGR_REC_GROUPREF,
    --     I.INTEGR_REC_STATUS
