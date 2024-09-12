/**
 * Copy column renaming
 * Duplicate "subscribers" from source pipeline to sink pipeline
 */

declare @MappingSetID nvarchar(50) = N'DTS - DCS Documents Renaming'

declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @Subsea uniqueidentifier = 'fb36536c-db59-4926-952a-5868262a44a5',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare
    @SourceGroupRef uniqueidentifier = @Yggdrasil,
    @SinkGroupRef uniqueidentifier = @Subsea

-- INSERT INTO dbo.atbl_Integrations_Configurations_FieldMappingSets_Subscribers
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
    [GroupRef] = @SinkGroupRef,
    [TargetTable],
    [CriteriaField1],
    [CriteriaField2],
    [FromField],
    [ToField],
    [Required]
FROM
    dbo.atbl_Integrations_Configurations_FieldMappingSets_Subscribers AS S WITH (NOLOCK)
WHERE
    [MappingSetID] = @MappingSetID
    and GroupRef = @SourceGroupRef
ORDER BY
    [TargetTable]