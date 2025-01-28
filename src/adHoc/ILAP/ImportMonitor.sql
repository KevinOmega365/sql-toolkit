select
    Projects_RAW = (select Count = count(*) from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Projects_RAW with (nolock)),
    ProjectsActivities_RAW = (select Count = count(*) from dbo.ltbl_Import_ILAP_PcProjBaselineExp_ProjectsActivities_RAW with (nolock)),
    Projects = (select Count = count(*) from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Projects with (nolock)),
    Activities = (select Count = count(*) from dbo.atbl_PC_ProjBaseline_Exp_ILAPMhrs with (nolock))

select * from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Queue with (nolock)

select * from dbo.ltbl_Import_ILAP_PcProjBaselineExp_Log with (nolock) order by Created desc
