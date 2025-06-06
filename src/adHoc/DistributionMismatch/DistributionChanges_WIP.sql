
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
    -- URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)',
    Domain,
    DocumentID,
    RevisionCreated,
    DistChanges
from
    (
        select -- top 10 -- random sample
            Domain,
            DocumentID,
            RevisionCreated = convert(nvarchar(10), RevisionCreated, 120),
            DistChanges =
                string_agg(
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
                    as nvarchar(max))
                    , ''
                ) within group (order by DocLogCreated)
        from
        (
            select
                Documents.Domain,
                Documents.DocumentID,
                RevisionCreated = CurrentRev.Created,
                CustomFieldName = coalesce((select FieldName from @FieldNameMapping f where f.ColumnName = DocLog.FieldName), DocLog.FieldName),
                DocLogCreated = DocLog.Created,
                DocLogFieldName = DocLog.FieldName,
                DocLogOldValue = DocLog.OldValue,
                DocLogFieldValue = DocLog.FieldValue
            from
                dbo.atbl_DCS_Documents Documents with (nolock)
                join dbo.atbl_DCS_Revisions CurrentRev with (nolock)
                    on CurrentRev.Domain = Documents.Domain
                    and CurrentRev.DocumentID = Documents.DocumentID
                    and CurrentRev.Revision = Documents.CurrentRevision
                join dbo.atbl_DCS_DocumentsLog DocLog with (nolock)
                    on DocLog.Domain = Documents.Domain
                    and DocLog.DocumentID = Documents.DocumentID
                -- join dbo.atbl_DCS_DistributionSetupLog as DistLog with (nolock)
                --     on DistLog.Domain = Documents.Domain
                --     and DistLog.DocumentID = Documents.DocumentID
            where
                Documents.currentRevision is not null
                and DocLog.Created > CurrentRev.Created
                and Documents.CreatedBy = 'af_Integrations_ServiceUser'
                and DocLog.CreatedBy = 'af_Integrations_ServiceUser'
                -- and DistLog.CreatedBy = 'af_Integrations_ServiceUser'
                and DocLog.FieldName in (
                    'AssetCustomText1',
                    'DocsCustomText1',
                    'DocsCustomText2',
                    'DocsCustomText3',
                    'DocsCustomText4',
                    'Flag',
                    'InstanceCustomText2',
                    'InstanceCustomText3'
                )
                and Documents.Domain in (
                    -- '145',
                    -- '153',
                    -- '181',
                    '128',
                    '175',
                    '187'
                )
        ) U
        group by
            Domain,
            DocumentID,
            RevisionCreated
        -- order by
        --     newid() -- random sample
    ) T

-- select count(*) from dbo.atbx_DCS_DistributionSetupLog where CreatedBy = 'af_Integrations_ServiceUser'
