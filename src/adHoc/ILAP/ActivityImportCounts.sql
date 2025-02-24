
SELECT
    Description,
    Id,
    ReportScheduleTypeId,
    CutoffDate,
    PointsInTimeType,
    ReportedActivityCount,
    ActivityImportCount,
    PimsActivityCount,
    ActivityDiff = ActivityImportCount - PimsActivityCount,
    PercentChange = format((ActivityImportCount - PimsActivityCount) / (1.0 * PimsActivityCount), 'P2')
FROM
(
    SELECT
        ProjectsDetails.description,
        ProjectsDetails.id,
        ProjectsDetails.reportScheduleTypeId,
        ProjectsDetails.cutoffDate,
        ProjectsDetails.pointsInTimeType,
        ReportedActivityCount = ProjectsDetails.activitiesCount,
        ActivityImportCount = (
            SELECT COUNT(*)
            FROM
                dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities_RAW PAR WITH (NOLOCK)
                CROSS APPLY openjson(RawJSON, '$.data.reportScheduleByIdWithRevisions[0].activities')
            WHERE
                PAR.PrimKey = ProjectsActivities.PrimKey
        ),
        PimsActivityCount = (
            SELECT COUNT(*)
            FROM
                dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs PreImportData WITH (NOLOCK)
            WHERE
                ProjectsDetails.ID = PreImportData.ReportScheduleId
        )
        FROM
            dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities_RAW AS ProjectsActivities WITH (NOLOCK)
            JOIN dbo.ltbl_Import_ILAP_PcProjBaselineExp_Projects AS ProjectsDetails WITH (NOLOCK)
                ON ProjectsDetails.ID = json_value(ProjectsActivities.RawJSON, '$.data.reportScheduleByIdWithRevisions[0].ReportScheduleId')
) T
ORDER BY
    Description
