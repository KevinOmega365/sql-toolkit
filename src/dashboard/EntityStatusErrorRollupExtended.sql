declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde',
    @Subsea uniqueidentifier = 'fb36536c-db59-4926-952a-5868262a44a5'

declare
    @DocumentEntity nvarchar(64) = 'Document',
    @RevisionEntity nvarchar(64) = 'Revision',
    @RevisionsFilesEntity nvarchar(64) = 'RevisionsFiles',
    @BoundaryDrawingsEntity nvarchar(64) = 'BoundaryDrawings',
    @DocumentsPlansEntity nvarchar(64) = 'DocumentsPlans',
    @ApprovalTrayEntity nvarchar(64) = 'ApprovalTray'

declare
    @GroupRef nvarchar(36) = '%',
    @Entity nvarchar(64 )= @DocumentEntity

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
    Trace,
    Count = count(*)
from
    (
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Document',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'Revision',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'RevisionsFiles',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = null,
            Entity = 'ResponseToComments',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_ResponseToComments with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = CMS_Domain,
            Entity = 'BoundaryDrawings',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_BoundaryDrawings with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'DocumentsPlans',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_DocumentsPlan with (nolock)
        
        union all
        
        select
            GroupRef = INTEGR_REC_GROUPREF,
            Domain = DCS_Domain,
            Entity = 'ApprovalTray',
            Status = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Trace = INTEGR_REC_TRACE
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems with (nolock)
    )
    EntityStatusError
where
    GroupRef like @GroupRef
    and Entity = @Entity
group by rollup
    (
        GroupRef,
        Domain,
        Entity,
        Status,
        Error,
        Trace
    )
order by
    Pipeline,
    Domain,
    Entity,
    Status,
    Error

-- for json auto