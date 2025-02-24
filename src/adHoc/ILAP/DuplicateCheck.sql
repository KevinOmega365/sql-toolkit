/*
 * Check counts for duplicate records
 */
select

    AllRecords =
    (
        select count(*)
        from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
    ),

    DistinctReportActivityIDs =
    (
        select count(*)
        from (
            select ReportScheduleId, ActId
            from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
            group by ReportScheduleId, ActId
        ) T
    )