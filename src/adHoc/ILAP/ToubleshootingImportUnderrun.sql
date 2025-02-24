
/*
 * How many of the missing files are deleted?
 */
select distinct
    Count = count(InPims.PrimKey) over (partition by InPims.IsDeleted),
    InPims.IsDeleted
from
    dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs InPims with (nolock)
    left join dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities FromImport with (nolock)
        on FromImport.ReportScheduleId = InPims.ReportScheduleId
        and FromImport.ActId = InPims.ActId
where
    FromImport.PrimKey is null

/*
 * Random Sample
 */
-- select top 50 
--     InPims.ScheduleTypeId,
--     InPims.ReportScheduleId,
--     InPims.Cutoff,
--     InPims.ContractId, 
--     InPims.ProjectName,
--     InPims.OriginatorCompany,
--     InPims.ActId,
--     InPims.ActCode, 
--     InPims.Cancelled,
--     InPims.ActDescr,
--     InPims.TotalQty,
--     InPims.DiscCode, 
--     InPims.DiscDescr,
--     InPims.PhaseCode,
--     InPims.PhaseDescr,
--     InPims.Plant, 
--     InPims.BuildBlockCode,
--     InPims.BuildBlockDescr,
--     InPims.FieldName,
--     InPims.ProjectDescription, 
--     InPims.ActualWorkHoursAtCutoffCumulative,
--     InPims.IsDeleted,
--     InPims.PBSCode,
--     InPims.SABCode, 
--     InPims.CORCode
-- from
--     dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs InPims with (nolock)
--     left join dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities FromImport with (nolock)
--         on FromImport.ReportScheduleId = InPims.ReportScheduleId
--         and FromImport.ActId = InPims.ActId
-- where
--     FromImport.PrimKey is null
-- order by
--     newid()

/*
 * Missing Activity Count
 */
-- select count(*)
-- from
--     dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs InPims with (nolock)
--     left join dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities FromImport with (nolock)
--         on FromImport.ReportScheduleId = InPims.ReportScheduleId
--         and FromImport.ActId = InPims.ActId
-- where
--     FromImport.PrimKey is null

/*
 * Data shape ILAP Mhrs
 */
-- select top 50 *
-- from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock)
-- order by newid()