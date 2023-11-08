/**
 * Distribution Flag Field Labels
 */
DECLARE @DistributionFlagFields NVARCHAR(MAX) = '[
        "AssetCustomText1",
        "DocsCustomText1",
        "DocsCustomText2",
        "DocsCustomText3",
        "DocsCustomText4",
        "Flag",
        "InstanceCustomText2",
        "InstanceCustomText3"
    ]'

DECLARE @DomainList NVARCHAR(MAX) = '[
    "128",
    "145",
    "153",
    "175",
    "181",
    "187"
]'

select
    Domain,
    ColumnName,
    Label
from
    (
        select
            Domain = Domains.value,
            ColumnName = CustomText.value,
            Label = ISNULL(
                coalesce(
                    (
                        SELECT Caption
                        FROM dbo.atbl_DCS_CustomFields with (nolock)
                        WHERE
                            [Domain] = Domains.value
                            AND CustomField = CustomText.value
                    ),
                    (
                        SELECT Caption
                        FROM dbo.atbl_DCS_InstanceCustomFields with (nolock)
                        WHERE InstanceCustomField = CustomText.value
                    )
                ),
                CustomText.value
            )
        from
            openjson (@DomainList) Domains
            cross join openjson (@DistributionFlagFields) CustomText
    ) T
where
    ColumnName = Label
order by
    Domain,
    ColumnName