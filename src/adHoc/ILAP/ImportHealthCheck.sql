/**
 * LastImport: 
 * ImportFreshness: Maximal value means loaded on the last run. Everything *should* be 1
 * ProjectReports.Status should be "OK" : "Ready" indicates that the was not imported into the atbl_PC_ProjBaseline_Exp_ILAPMhrs on the last run
 * MimMaxImportTimespan: Should be 0 : any value that could span multiple run would imply multiple imports and duplicated records
 */
select
    ProjectReports.PrimKey,
    ProjectReports.ID,
    ProjectReports.Description,
    ProjectReports.PointsInTimeType,
    ActivityRecordStatistics.ActivityCount,
    LastFetch = ActivityRaw.Created,
    LastImport = ActivityRecordStatistics.MaxActivityCreation,
    ImportFreshness = rank() over (order by dateadd(hour, datediff(hour, 0, ActivityRecordStatistics.MaxActivityCreation), 0)), -- round to the nearest hour (see ref)
    MinMaxImportTimespan = ActivityCreationTimeSpanSeconds,
    ProjectReports.Status, -- Should be "OK" : "Ready" indicates that the was not imported into the atbl_PC_ProjBaseline_Exp_ILAPMhrs
    ProjectReports.StatusMessage
from
    dbo.ltbl_Import_ILAP_PcProjBaselineExp_Projects as ProjectReports with (nolock)
    join
    (
        select
            ReportScheduleID,
            ActivityCount = count(*),
            MinActivityCreation = min(Created),
            MaxActivityCreation = max(Created),
            ActivityCreationTimeSpanSeconds = datediff(second, max(Created), min(Created))
        from
            dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
        group by
            ReportScheduleID
    )
    ActivityRecordStatistics
        on ActivityRecordStatistics.ReportScheduleID = ProjectReports.id
    join dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities_RAW as ActivityRaw with (nolock)
        on ProjectReports.ID = json_value(ActivityRaw.RawJSON, '$.data.reportScheduleByIdWithRevisions[0].ReportScheduleId')



-- select
--     ReportScheduleID,
--     count(*),
--     min(Created),
--     max(Created),
--     datediff(second, max(Created), min(Created))
-- from
--     dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
-- group by
--     ReportScheduleID

-- select top 50 *
-- from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
-- order by newid()

-- select count(*)
-- from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)


-- ref: https://stackoverflow.com/questions/6666866/t-sql-datetime-rounded-to-nearest-minute-and-nearest-hours-with-using-functions
