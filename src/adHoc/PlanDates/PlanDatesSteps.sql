
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Yggdrasil -- '%'

/*
 * steps by pipeline
 */
select
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
        where STCG.PrimKey = P.INTEGR_REC_GROUPREF
    ),
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    InstanceCount = count(*)
from
    dbo.ltbl_Import_DTS_DCS_DocumentsPlan P with (nolock)
    join dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
        on D.DCS_Domain = P.DCS_Domain
        and D.DCS_DocumentID = P.DCS_DocumentID
        and D.INTEGR_REC_GROUPREF = P.INTEGR_REC_GROUPREF
        and D.INTEGR_REC_BATCHREF = P.INTEGR_REC_BATCHREF
where
    P.INTEGR_REC_STATUS <> 'ACTION_DELETE'
    and P.INTEGR_REC_GROUPREF like @GroupRef
group by
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    P.INTEGR_REC_GROUPREF
order by
    Pipeline,
    P.DCS_Step,
    P.DCS_ReasonForIssue

/*
 * steps by domain
 */
select
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
        where STCG.PrimKey = P.INTEGR_REC_GROUPREF
    ),
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    InstanceCount = count(*)
from
    dbo.ltbl_Import_DTS_DCS_DocumentsPlan P with (nolock)
    join dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
        on D.DCS_Domain = P.DCS_Domain
        and D.DCS_DocumentID = P.DCS_DocumentID
        and D.INTEGR_REC_GROUPREF = P.INTEGR_REC_GROUPREF
        and D.INTEGR_REC_BATCHREF = P.INTEGR_REC_BATCHREF
where
    P.INTEGR_REC_STATUS <> 'ACTION_DELETE'
    and P.INTEGR_REC_GROUPREF like @GroupRef
group by
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    P.INTEGR_REC_GROUPREF
order by
    Pipeline,
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue

/*
 * steps by domain verbose
 */
select
    Pipeline = (
        select Name
        from dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
        where STCG.PrimKey = P.INTEGR_REC_GROUPREF
    ),
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    D.companyDistribution,
    D.otherCompanyDistributions,
    InstanceCount = count(*)
from
    dbo.ltbl_Import_DTS_DCS_DocumentsPlan P with (nolock)
    join dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
        on D.DCS_Domain = P.DCS_Domain
        and D.DCS_DocumentID = P.DCS_DocumentID
        and D.INTEGR_REC_GROUPREF = P.INTEGR_REC_GROUPREF
        and D.INTEGR_REC_BATCHREF = P.INTEGR_REC_BATCHREF
where
    P.INTEGR_REC_STATUS <> 'ACTION_DELETE'
    and P.INTEGR_REC_GROUPREF like @GroupRef
group by
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    D.companyDistribution,
    D.otherCompanyDistributions,
    P.INTEGR_REC_GROUPREF
order by
    Pipeline,
    P.DCS_Domain,
    P.DCS_Step,
    P.DCS_ReasonForIssue,
    D.companyDistribution,
    D.otherCompanyDistributions

/*
 * sample (steps)
 */
-- select top 10
--     Pipeline = (
--         select Name
--         from dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG with (nolock)
--         where STCG.PrimKey = P.INTEGR_REC_GROUPREF
--     ),
--     P.DCS_Domain,
--     P.DCS_Step,
--     P.DCS_ReasonForIssue,
--     D.companyDistribution,
--     D.otherCompanyDistributions
-- from
--     dbo.ltbl_Import_DTS_DCS_DocumentsPlan P with (nolock)
--     join dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
--         on D.DCS_Domain = P.DCS_Domain
--         and D.DCS_DocumentID = P.DCS_DocumentID
--         and D.INTEGR_REC_GROUPREF = P.INTEGR_REC_GROUPREF
--         and D.INTEGR_REC_BATCHREF = P.INTEGR_REC_BATCHREF
-- where
--     P.INTEGR_REC_STATUS <> 'ACTION_DELETE'
-- order by
--     newid()

/*
 * plan (sample)
 */
-- select top 10 *
-- from dbo.ltbl_Import_DTS_DCS_DocumentsPlan with (nolock)
-- where INTEGR_REC_STATUS <> 'ACTION_DELETE'
-- order by newid()

/*
 * row count
 */
-- select count(*)
-- from dbo.ltbl_Import_DTS_DCS_DocumentsPlan with (nolock)
