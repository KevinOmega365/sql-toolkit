declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Yggdrasil -- '%' --

    select
        Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups stcg with (nolock) where stcg.Primkey = D.integr_rec_groupref),
        ErrorCount = count(*),
        ObjectType = 'Documents',
        NewErrorMessageHits = (
            select count(*)
            from dbo.aviw_Integrations_Configurations_ErrorMappings as ErrorMappings
            where
            trim(integr_rec_error) like ErrorMappings.OldErrorDescription + '%'
            -- AND integr_rec_groupref = ErrorMappings.GroupRef
        ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_Documents as D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        and integr_rec_status not in  ('OUT_OF_SCOPE')
        and isnull(integr_rec_error, '') <> ''
    group by
        integr_rec_groupref,
        integr_rec_error

union all

    select
        Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups stcg with (nolock) where stcg.Primkey = D.integr_rec_groupref),
        ErrorCount = count(*),
        ObjectType = 'Revisions',
        NewErrorMessageHits = (
            select count(*)
                FROM dbo.aviw_Integrations_Configurations_ErrorMappings AS ErrorMappings
                WHERE
                TRIM(integr_rec_error) LIKE ErrorMappings.OldErrorDescription + '%'
                -- AND integr_rec_groupref = ErrorMappings.GroupRef
            ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_Revisions as D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        and integr_rec_status not in  ('OUT_OF_SCOPE')
        and isnull(integr_rec_error, '') <> ''
    group by
        integr_rec_groupref,
        integr_rec_error

union all

    select
        Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups stcg with (nolock) where stcg.Primkey = D.integr_rec_groupref),
        ErrorCount = count(*),
        ObjectType = 'RevisionsFiles',
        NewErrorMessageHits = (
            select count(*)
                FROM dbo.aviw_Integrations_Configurations_ErrorMappings AS ErrorMappings
                WHERE
                TRIM(integr_rec_error) LIKE ErrorMappings.OldErrorDescription + '%'
                -- AND integr_rec_groupref = ErrorMappings.GroupRef
            ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        and integr_rec_status not in  ('OUT_OF_SCOPE')
        and isnull(integr_rec_error, '') <> ''
    group by
        integr_rec_groupref,
        integr_rec_error

order by
    Pipeline,
    ErrorCount desc