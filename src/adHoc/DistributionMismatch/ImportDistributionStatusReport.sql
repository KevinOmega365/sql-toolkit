
-------------------------------------------------------------------------------
---------------------------------------------- Start: Map Custom Field Names --
-------------------------------------------------------------------------------

DECLARE @DistributionFlagColumns NVARCHAR(MAX)  = '[
    "AssetCustomText1",
    "DocsCustomFreeText1",
    "DocsCustomText1",
    "DocsCustomText2",
    "DocsCustomText3",
    "DocsCustomText4",
    "Flag",
    "InstanceCustomText2",
    "InstanceCustomText3"
]'

-------------------------------------------------------------------------------

declare @Domain nvarchar(128) = '128'

declare @FieldNameMapping table
(
    ColumnName nvarchar(128),
    FieldName nvarchar(128)
)

-------------------------------------------------------------------------------

insert into @FieldNameMapping (
    ColumnName,
    FieldName
)
select
    ColumnName = value,
    FieldName = COALESCE(
        (
            SELECT Caption
            FROM dbo.atbl_DCS_CustomFields with (nolock)
            WHERE
                [Domain] = @Domain
                AND CustomField = value
        ),
        (
            SELECT Caption
            FROM dbo.atbl_DCS_InstanceCustomFields with (nolock)
        WHERE InstanceCustomField = value
        ),
        value
    )
from
    openjson(@DistributionFlagColumns)

-------------------------------------------------------------------------------
------------------------------------------------ End: Map Custom Field Names --
-------------------------------------------------------------------------------

select
    Domain,
    DocumentID,
    URL,
    HasCompanyDistMismatch,
    HasDistFlagStepMismatch,
    HasDistChanges,
    Revision,
    DocWorkflowStatus,
    HasReviewResponsible,
    -- IsSuperseded, -- just not that interesting
    -- IsVoided, -- just not that interesting
    Step,
    DCS_Step,
    Criticality,
    DCS_Criticality,
    companyDistribution,
    otherCompanyDistributions,
    [Aker BP Review],
    [CED],
    [TI Allseas/EMC Topside Allseas],
    [TI Heerema],
    [PFS (Incl. Akso, MUC and Equinor)],
    [Munin (Aibel)],
    Flag,
    [ModificationAlliance],
    [SubseaAlliance],
    RevisionCreated,
    DistChanges
from
(
    select
        D.Domain,
        D.DocumentID,
        URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)',
        R.Revision,
        DocWorkflowStatus = isnull(D.DocWorkflowStatus, ''),
        HasReviewResponsible = case
            when
                exists (
                    select *
                    from
                        dbo.atbl_DCS_DistributionSetup as DS with (nolock)
                        inner join dbo.atbl_DCS_ActionTypes as AT with (nolock)
                            on AT.ActionType = DS.ActionType
                            and AT.SystemActionType = 'Review Responsible'
                    where
                        DS.Domain = D.Domain
                        and DS.DocumentID = D.DocumentID
                        -- and P.PersonID = DS.ReceiverPerson
                        and DS.DistributionType = 'Review'
                )
            then cast(1 as bit)
            else cast(0 as bit)
        end,
        D.IsSuperseded,
        D.IsVoided,
        R.Step,
        IR.DCS_Step,
        D.Criticality,
        ID.DCS_Criticality,
        ID.companyDistribution,
        otherCompanyDistributions = isnull(ID.otherCompanyDistributions_CONCATENATED, ''),
        [Aker BP Review] = isnull(D.AssetCustomText1, ''),
        [CED] = isnull(D.DocsCustomFreeText1, ''),
        [TI Allseas/EMC Topside Allseas] = isnull(D.DocsCustomText1, ''),
        [TI Heerema] = isnull(D.DocsCustomText2, ''),
        [PFS (Incl. Akso, MUC and Equinor)] = isnull(D.DocsCustomText3, ''),
        [Munin (Aibel)] = isnull(D.DocsCustomText4, ''),
        Flag = isnull(D.Flag, ''),
        [ModificationAlliance] = isnull(D.InstanceCustomText2, ''),
        [SubseaAlliance] = isnull(D.InstanceCustomText3, ''),
        HasImportPimsMismatch = case
            when Step <> DCS_Step
            then cast(1 as bit)
            else cast(0 as bit)
        end,
        HasCompanyDistMismatch = case
            when
                D.AssetCustomText1 = 'C' and R.Step not like '%R'
                or D.AssetCustomText1 = 'I' and R.Step not like '%I'

            then cast(1 as bit)
            else cast(0 as bit)
        end,
        HasDistFlagStepMismatch = case
            when
                (
                    isnull(D.DocsCustomFreeText1 , '') = 'C'
                    or isnull(D.DocsCustomText1, '') = 'C'
                    or isnull(D.DocsCustomText2, '') = 'C'
                    or isnull(D.DocsCustomText3, '') = 'C'
                    or isnull(D.DocsCustomText4, '') = 'C'
                    or isnull(D.Flag, '') = 'D&W-C'
                    or isnull(D.InstanceCustomText2, '') = 'C'
                    or isnull(D.InstanceCustomText3, '') = 'C'
                )
                and R.Step not like '%R'

            then cast(1 as bit)
            else cast(0 as bit)
        end,
        HasDistChanges =
            case
                when exists (
                    SELECT
                        Created,
                        FieldName,
                        OldValue,
                        FieldValue,
                        CreatedBy
                    FROM
                        dbo.atbl_DCS_DocumentsLog DL WITH (NOLOCK)
                    WHERE
                        DL.Domain = D.Domain
                        AND DL.DocumentID = D.DocumentID
                        AND DL.Created > R.Created
                        AND DL.FieldName in (
                            'AssetCustomText1',
                            'DocsCustomText1',
                            'DocsCustomText2',
                            'DocsCustomText3',
                            'DocsCustomText4',
                            'Flag',
                            'InstanceCustomText2',
                            'InstanceCustomText3'
                        )
                )
                then cast(1 as bit)
                else cast(0 as bit)
            end,
        RevisionCreated = R.Created,
        DistChanges = (
            select string_agg(
                cast(
                    '( ' +
                    convert(nvarchar(10), DocLogCreated, 120) +
                    ' ' +
                    CustomFieldName +
                    ' : ' +
                    isnull(DocLogOldValue, 'NULL') +
                    ' > ' +
                    isnull(DocLogFieldValue, 'NULL') +
                    ' )'
                    as nvarchar(max)
                )
                , ''
            ) within group (order by DocLogCreated)
            from (
                SELECT
                    CustomFieldName = coalesce(
                        (
                            select FieldName
                            from @FieldNameMapping f
                            where f.ColumnName = DL.FieldName
                        ),
                        DL.FieldName),
                    DocLogCreated = DL.Created,
                    DocLogFieldName = DL.FieldName,
                    DocLogOldValue = DL.OldValue,
                    DocLogFieldValue = DL.FieldValue
                FROM
                    dbo.atbl_DCS_DocumentsLog DL WITH (NOLOCK)
                WHERE
                    DL.Domain = D.Domain
                    AND DL.DocumentID = D.DocumentID
                    AND DL.Created > R.Created
                    AND DL.FieldName in (
                        'AssetCustomText1',
                        'DocsCustomText1',
                        'DocsCustomText2',
                        'DocsCustomText3',
                        'DocsCustomText4',
                        'Flag',
                        'InstanceCustomText2',
                        'InstanceCustomText3'
                    )
            ) T
        )
    from
        dbo.ltbl_Import_DTS_DCS_Documents ID with (nolock)
        join dbo.atbl_DCS_Documents D with (nolock)
            on D.Domain = ID.DCS_Domain
            and D.DocumentID = ID.DCS_DocumentID
        join dbo.atbl_DCS_Revisions R with (nolock)
            on R.Domain = D.Domain
            and R.DocumentID = D.DocumentID
            and R.Revision = D.CurrentRevision
        join dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
            on IR.DCS_Domain = R.Domain
            and IR.DCS_DocumentID = R.DocumentID
            and IR.DCS_Revision = R.Revision
    where
        D.Domain in ('128', '187')
        and D.IsSuperseded = 0
        and D.IsVoided = 0
) U
where
    HasCompanyDistMismatch = 1
    or HasDistFlagStepMismatch = 1
    or HasImportPimsMismatch = 1
