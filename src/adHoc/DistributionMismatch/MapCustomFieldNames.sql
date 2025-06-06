/*
 * Map Custom Field Names
 */

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
                AND CustomField = ''' + @CustomFieldName + '''
        ),
        (
            SELECT Caption
            FROM dbo.atbl_DCS_InstanceCustomFields with (nolock)
        WHERE InstanceCustomField = ''' + @CustomFieldName + '''
        )
    )
from
    openjson(@DistributionFlagColumns)

-------------------------------------------------------------------------------

select * from @FieldNameMapping