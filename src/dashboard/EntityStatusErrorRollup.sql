
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef uniqueidentifier = @Valhall

/*
 * Entity Status Error Rollup
 */
select
    -- GroupRef,
    Pipeline = (select Name from dbo.atbl_Integrations_ScheduledTasksConfigGroups G with (nolock) where G.Primkey = EntityStatusError.GroupRef),
    Domain,
    Entity,
    Status,
    Error,
    Count = count(*)
from
    (
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Document',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Revision',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'RevisionsFiles',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
    )
    EntityStatusError
where
    GroupRef = @GroupRef
group by rollup
    (
        GroupRef,
        Domain,
        Entity,
        Status,
        Error
    )
