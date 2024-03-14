

declare @ColumnRenaming table (
    dcs_column nvarchar(128),
    dts_column nvarchar(128)
)
insert into @ColumnRenaming
values
    ('DCS_DocumentType', 'documentTypeShortCode'),
    ('DCS_Title', 'documentTitle'),
    ('DCS_Discipline', 'disciplineCode'),
    ('DCS_FacilityID', 'facilityCode'),
    ('DCS_OriginatorCompany', 'originatingContractor'),
    ('DCS_ReviewClass', ' reviewClass')

declare @Param0 nvarchar(50) = 'UPP DTS - DCS Documents Renaming'

-- insert into [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers]
-- (
--     [MappingSetID],
--     [GroupRef],
--     [TargetTable],
--     [CriteriaField1],
--     [CriteriaField2],
--     [FromField],
--     [ToField],
--     [Required]
-- )
SELECT
    [MappingSetID],
    [GroupRef],
    [TargetTable],
    [CriteriaField1],
    [CriteriaField2],
    [FromField] = dts_column,
    [ToField] = dcs_column,
    [Required]
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] WITH (NOLOCK)
    cross join @ColumnRenaming
WHERE
    [MappingSetID] = @Param0
