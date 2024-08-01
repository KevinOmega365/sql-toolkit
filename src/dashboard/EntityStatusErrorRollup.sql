declare @GroupRef uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

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
