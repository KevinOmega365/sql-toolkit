/**
 * Positive integration counts
 */

declare @Domain nvarchar(128) = '181'

select
    [count_document_creation] =
    (
        select count(*)
        from dbo.atbl_DCS_Documents D with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    [count_document_updates] =
    (
        select count(*)
        from dbo.atbl_DCS_Documents D with (nolock)
        where
            Created < dateadd(week, -1, getdate())
            and UpdatedBy like 'af_Integrations_ServiceUser'
            and Updated > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    [count_revision_creation] =
    (
        select count(*)
        from dbo.atbl_DCS_Revisions R with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    ),
    [count_revision_file_creation] =
    (
        select count(*)
        from dbo.atbl_DCS_RevisionsFiles RF with (nolock)
        where
            CreatedBy like 'af_Integrations_ServiceUser'
            and Created > dateadd(week, -1, getdate())
            and Domain = @Domain
    )