declare @MatchingRules table
(
    Pattern nvarchar(max)
)
insert into @MatchingRules
values
    ('FAILED%UI_atbl_DCS_RevisionsFiles_UniqueFileName%'),
    ('FAILED%Document is currently being reviewed%'),
    ('FAILED%FK_atbl_DCS_Documents_atbl_Asset_FacilitiesAreas%'),
    ('FAILED% Document has ongoing review(s)%'),
    ('DCS_OriginatorCompany is null'),
    ('Documents can not start with anything else then PWP or FEN'),
    ('DocumentType RG is not valid'),
    ('Domain is 148 - Power from Shore'),
    ('Invalid DocumentGroup-DocumentType-PlantID (%, %, %)%'),
    ('Missing DocumentType-Step combination (%, %)%'),
    ('Parent document has not passed validation'),
    ('Parent document is out of scope'),
    ('Parent revision has not passed validation'),
    ('Parent revision is out of scope'),
    ('Missing Physical File'),
    ('Multiple scope messages'),
    ('Multiple validation messages'),
    ('No Step defined for ReasonForIssue-CompanyDistribution-DistrbutionFlags (%,%,%)%'),
    ('Not connected to a physical file'),
    ('Not connected to a revision and document'),
    ('Out of scope: older revision without Files'),
    ('PN document-revisions without files are disregarded'),
    ('Quallity Failure: Revision without Files'),
    ('revisionStatus is not one of the legal values ( 1-5, OF, S, VOID )'),
    ('SupersededBy is NULL.'),
    ('The PO Number (%) is not configured in Pims for the Contract No (%)')

-------------------------------------------------------------------------------

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Yggdrasil -- '%' --

-------------------------------------------------------------------------------

    select
        Pipeline = (select name from dbo.atbl_Integrations_ScheduledTasksConfigGroups stcg with (nolock) where stcg.Primkey = D.integr_rec_groupref),
        ErrorCount = count(*),
        ObjectType = 'Documents',
        NewErrorMessageHits = (
            select count(*)
            from @MatchingRules as ErrorMappings
            where
            trim(integr_rec_error) like ErrorMappings.Pattern
            -- AND integr_rec_groupref = ErrorMappings.GroupRef
        ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_Documents as D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        -- and integr_rec_status not in  ('OUT_OF_SCOPE')
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
                FROM @MatchingRules AS ErrorMappings
                WHERE
                TRIM(integr_rec_error) LIKE ErrorMappings.Pattern
                -- AND integr_rec_groupref = ErrorMappings.GroupRef
            ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_Revisions as D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        -- and integr_rec_status not in  ('OUT_OF_SCOPE')
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
                FROM @MatchingRules AS ErrorMappings
                WHERE
                TRIM(integr_rec_error) LIKE ErrorMappings.Pattern
                -- AND integr_rec_groupref = ErrorMappings.GroupRef
            ),
        integr_rec_error
    from
        dbo.ltbl_Import_DTS_DCS_RevisionsFiles AS D with (nolock)
    where
        integr_rec_groupref like @GroupRef
        -- and integr_rec_status not in  ('OUT_OF_SCOPE')
        and isnull(integr_rec_error, '') <> ''
    group by
        integr_rec_groupref,
        integr_rec_error

order by
    Pipeline,
    ErrorCount desc
