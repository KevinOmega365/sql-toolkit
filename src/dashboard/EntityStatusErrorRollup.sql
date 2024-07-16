/*
 * Entity Status Error Rollup
 */
select
    Pipeline = (select Name from dbo.atbl_Integrations_ScheduledTasksConfigGroups G with (nolock) where G.Primkey = EntityStatusError.Pipeline),
    Domain,
    Entity,
    Status,
    Error,
    Count = count(*)
from
    (
        select
            Pipeline = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Document',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        
        union all
        
        select
            Pipeline = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Revision',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        
        union all
        
        select
            Pipeline = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'RevisionsFiles',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
    )
    EntityStatusError
group by rollup
    (
        Pipeline,
        Domain,
        Entity,
        Status,
        Error
    )