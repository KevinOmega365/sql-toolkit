declare @documentID nvarchar(128) = 'FPQ-LEI-N-XG-11161-03'

/*
 * Revision-file existence check from assign actions procedure
 */
-- select count(*)

--     FROM
--         dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS RF WITH (NOLOCK)
--         INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
--             ON F.object_guid = RF.object_guid
--         INNER JOIN dbo.stbl_System_Files AS SF WITH (NOLOCK)
--             ON SF.PrimKey = F.FileRef
--     WHERE
--         EXISTS (
--             SELECT *
--             FROM
--                 dbo.atbl_DCS_RevisionsFiles AS DRF WITH (NOLOCK)
--                 INNER JOIN dbo.atbl_DCS_Revisions AS DR WITH (NOLOCK)
--                     ON DR.Domain = DRF.Domain
--                     AND DR.DocumentID = DRF.DocumentID
--                     AND DR.RevisionItemNo = DRF.RevisionItemNo
--                 INNER JOIN dbo.stbl_System_Files AS DRF_SF WITH (NOLOCK)
--                     ON DRF_SF.PrimKey = DRF.FileRef
--             WHERE
--                 DRF.Domain = RF.DCS_Domain
--                 AND DRF.DocumentID = RF.DCS_DocumentID
--                 AND DR.Revision = RF.Revision
--                 AND (
--                     DRF_SF.CRC = SF.CRC
--                     OR DRF.Import_ExternalUniqueRef = RF.DCS_Import_ExternalUniqueRef
--                 )
--         )
--         and RF.DCS_DocumentID = @documentID -- debug

/*
 * Revision-file update check from assign actions procedure
 */
-- select count(*)

--     FROM
--         dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
--         INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
--             ON F.object_guid = I.object_guid
--         INNER JOIN dbo.stbl_System_Files AS F_Sys WITH (NOLOCK)
--             ON F_Sys.PrimKey = F.FileRef
--         INNER JOIN dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
--             ON R.Domain = I.DCS_Domain
--             AND R.DocumentID = I.DCS_DocumentID
--             AND R.Revision = I.DCS_Revision
--         INNER JOIN dbo.atbl_DCS_RevisionsFiles AS RF WITH (NOLOCK)
--             ON RF.Domain = R.Domain
--             AND RF.DocumentID = R.DocumentID
--             AND RF.RevisionItemNo = R.RevisionItemNo
--         INNER JOIN dbo.stbl_System_Files RF_Sys WITH(NOLOCK)
--             ON RF_Sys.PrimKey = RF.FileRef
--     WHERE
--         (
--             RF_Sys.PrimKey = F_Sys.PrimKey -- DCS_FileRef is not set on revisions-files yet
--             OR RF_Sys.CRC = F_Sys.CRC -- Both CRC and FileRef are used to match "identity" on files
--         )
--         -- AND (
--         --     ISNULL(I.DCS_Type, '') <> ISNULL(RF.[Type],'')
--         --     OR ISNULL(I.DCS_FileDescription, '') <> ISNULL(RF.[FileDescription],'')
--         -- )
--         AND RF.CreatedBy = 'af_Integrations_ServiceUser'
--         -- AND I.INTEGR_REC_BATCHREF = @BatchRef
--         -- AND I.INTEGR_REC_STATUS IN (@VALIDATED_OK, @NO_CHANGE)
--         and I.DCS_DocumentID = @documentID -- debug

/*
 * File spot check
 */
        select
            RF.FileDescription,
            RF.FileRef,
            SF.CRC,
            ImportStatus = 'NA'
        from
            dbo.atbl_DCS_RevisionsFiles RF with (nolock)
            join dbo.stbl_System_Files SF with (nolock)
                on SF.PrimKey = RF.FileRef
        where
            DocumentID = @documentID
    union all
        select
            DCS_FileDescription,
            DCS_FileRef = F_Sys.PrimKey,
            F_Sys.CRC,
            ImportStatus = I.INTEGR_REC_STATUS
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS I WITH (NOLOCK)
            INNER JOIN dbo.ltbl_Import_DTS_DCS_Files AS F WITH (NOLOCK)
                ON F.object_guid = I.object_guid
            INNER JOIN dbo.stbl_System_Files AS F_Sys WITH (NOLOCK)
                ON F_Sys.PrimKey = F.FileRef
        where
            I.DCS_DocumentID = @documentID
