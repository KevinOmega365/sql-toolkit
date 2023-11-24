/**
 * Positive integration counts
 */

declare @Domain nvarchar(128) = '181'

select
    DocumentsCreated =
    (
        select count(*)
        from dbo.atbl_DCS_Documents D with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    DocumentsUpdated =
    (
        select count(*)
        from dbo.atbl_DCS_Documents D with (nolock)
        where
            datediff(minute, Created, Updated) > 1
            and UpdatedBy like 'af_Integrations_ServiceUser'
            and Updated > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    RevisionsCreated =
    (
        select count(*)
        from dbo.atbl_DCS_Revisions R with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    RevisionFilesCreated =
    (
        select count(*)
        from dbo.atbl_DCS_RevisionsFiles RF with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    )