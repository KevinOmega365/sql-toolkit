
-- declare @GroupRef uniqueidentifier = '93e48b03-aa47-48d8-90f1-9787332f8047' -- DTS (Aibel ProArc: MUNIN) - Documents
declare @GroupRef uniqueidentifier = 'cdfac83e-cc06-424d-9997-b38bb8a8cd7e' -- DTS (Aibel ProArc: IvarAasen) - Documents

/**
 * Import Counts
 */
-- select
--     Documents = (select count(*) from dbo.ltbl_Import_MuninAibel_Documents with (nolock) where INTEGR_REC_GROUPREF = @GroupRef),
--     Revisions = (select count(*) from dbo.ltbl_Import_MuninAibel_Revisions with (nolock) where INTEGR_REC_GROUPREF = @GroupRef),
--     RevisionFiles = (select count(*) from dbo.ltbl_Import_MuninAibel_RevisionFiles with (nolock) where INTEGR_REC_GROUPREF = @GroupRef),
--     Files = (select count(*) from dbo.ltbl_Import_MuninAibel_Files with (nolock) where INTEGR_REC_GROUPREF = @GroupRef)

/**
 *  Error counts by type
 */
select
    Count,
    Type,
    INTEGR_REC_ERROR
from 
    (
            select
                Count = count(*),
                Type = 'Documents',
                INTEGR_REC_ERROR
            from
                dbo.ltbl_Import_MuninAibel_Documents with (nolock)
            where
                INTEGR_REC_GROUPREF = @GroupRef
                and isnull(INTEGR_REC_ERROR, '') <> ''
            group by
                INTEGR_REC_ERROR

        union all

            select
                Count = count(*),
                Type = 'Revisions',
                INTEGR_REC_ERROR
            from
                dbo.ltbl_Import_MuninAibel_Revisions with (nolock)
            where
                INTEGR_REC_GROUPREF = @GroupRef
                and isnull(INTEGR_REC_ERROR, '') <> ''
            group by
                INTEGR_REC_ERROR

        union all

            select
                Count = count(*),
                Type = 'RevisionFiles',
                INTEGR_REC_ERROR
            from
                dbo.ltbl_Import_MuninAibel_RevisionFiles with (nolock)
            where
                INTEGR_REC_GROUPREF = @GroupRef
                and isnull(INTEGR_REC_ERROR, '') <> ''
            group by
                INTEGR_REC_ERROR

        union all

            select
                Count = count(*),
                Type = 'Files',
                INTEGR_REC_ERROR
            from
                dbo.ltbl_Import_MuninAibel_Files with (nolock)
            where
                INTEGR_REC_GROUPREF = @GroupRef
                and isnull(INTEGR_REC_ERROR, '') <> ''
            group by
                INTEGR_REC_ERROR

    ) AS GROUPED_ERRORS_BY_ENTITY
order by
    Count desc
 
/**
 * Integrations using this DB namespace
 */
-- select distinct
--     GroupTitle =
--         (
--             select Name
--             from dbo.atbl_Integrations_ScheduledTasksConfigGroups with (nolock)
--             where PrimKey = INTEGR_REC_GROUPREF
--         ),
--     INTEGR_REC_GROUPREF
-- from
--     dbo.ltbl_Import_MuninAibel_Documents with (nolock)