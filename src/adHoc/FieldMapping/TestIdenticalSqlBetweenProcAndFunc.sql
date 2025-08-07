
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @dummyBatchRef uniqueidentifier = newid()

declare
    @testGroupRef uniqueidentifier,
    @testTargetTable nvarchar(128)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

/*
 * Random test values
 */
select top 1
    @testGroupRef = GroupRef,
    @testTargetTable = TargetTable
from
    dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings PipelineMappings
where
    not exists (
        select *
        from dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings Mappings
        where
            Mappings.GroupRef = PipelineMappings.GroupRef
            and Mappings.TargetTable = PipelineMappings.TargetTable
            and MappingType = 'Rename'
    )
    -- and PipelineMappings.CriteriaField1 is not null
    -- and PipelineMappings.CriteriaField2 is not null
    -- and PipelineMappings.FromField is not null
    -- and PipelineMappings.FromValue  is not null
    -- and PipelineMappings.CriteriaValue1 is not null
    -- and PipelineMappings.CriteriaValue2 is not null
group by
    GroupRef,
    TargetTable
order by
    newid()

/*
 * Keep same values to repeat a test
 */
set @testGroupRef = 'bbe7217e-9376-468f-a911-94cf5a806bc8'
set @testTargetTable = 'ltbl_Import_CMS_ClassLibrary_Tags'

-- -- uses all three input column-values
-- set @testGroupRef = 'e8b280ec-2332-4e9e-89c9-13dda9e39bf5'
-- set @testTargetTable = 'ltbl_Import_Stage_CMS_Compl_ObjectsEventsChecklistItems'

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
declare @FunctionGenerated table (
    GroupRef uniqueidentifier,
    MappingSetID nvarchar(128),
    SqlStatement nvarchar(max)
)

-------------------------------------------------------------------------------
insert into @FunctionGenerated (
    GroupRef,
    MappingSetID,
    SqlStatement
)
SELECT
    GroupRef,
    MappingSetID,
    SqlStatement = dbo.lfnc_Import_DTS_DCS_FieldMappings_GetSql(
        BatchRef,
        MappingType,
        MappingSetJson
    )
FROM
    (
        SELECT
            GroupRef,
            BatchRef = @dummyBatchRef,
            MappingSetID,
            MappingSetJson = (
                SELECT
                    CriteriaField1,
                    CriteriaField2,
                    CriteriaValue1,
                    CriteriaValue2,
                    FromField,
                    FromValue,
                    MappingSetID,
                    MappingType,
                    PriorityOrder,
                    Required,
                    TargetTable,
                    ToField,
                    ToValue
                FROM dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings Mapping
                WHERE
                    Mapping.GroupRef = PipelineMappings.GroupRef
                    AND Mapping.MappingSetID = PipelineMappings.MappingSetID
                    AND Mapping.TargetTable = PipelineMappings.TargetTable
                    AND Mapping.FromField = PipelineMappings.FromField
                    AND Mapping.ToField = PipelineMappings.ToField
                FOR
                    JSON AUTO
            ),
            MappingType
        FROM
            dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings PipelineMappings
WHERE
    GroupRef = @testGroupRef
    AND TargetTable = @testTargetTable
        GROUP BY
            GroupRef,
            MappingSetID,
            TargetTable,
            FromField,
            ToField,
            MappingType
    ) T

-------------------------------------------------------------------------------
-- select
--     GroupRef,
--     MappingSetID,
--     SqlStatement
-- from
--     @FunctionGenerated

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
declare @ProcedureGenerated table (
    SqlStatement NVARCHAR(MAX),
    GroupRef UNIQUEIDENTIFIER,
    TableName NVARCHAR(128),
    MappingSetID NVARCHAR(128)
)
-------------------------------------------------------------------------------
insert into @ProcedureGenerated (
    SqlStatement,
    GroupRef,
    TableName,
    MappingSetID
)
exec dbo.astp_Integrations_Configurations_ApplyFieldMappings_testing_kfjb
    @testGroupRef,
    @dummyBatchRef,
    @testTargetTable
-------------------------------------------------------------------------------
-- select
--     ID,
--     SqlStatement,
--     StatementExecuted
-- from
--     @ProcedureGenerated
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

/*
 * do a full outer join to match the sql
 * work toward whitespace removal
 */
select
    FunctionalGroupRef = F.GroupRef,
    FunctionalMappingSetID = F.MappingSetID,
    FunctionalSql = F.SqlStatement,
    ProceduralSql = P.SqlStatement,
    ProceduralGroupRef = P.GroupRef,
    ProceduralTableName = P.TableName,
    ProceduralMappingSetID = P.MappingSetID
from
    @ProcedureGenerated P
    full outer join @FunctionGenerated F
        on
            replace(replace(F.SqlStatement, CHAR(13) + CHAR(10), ''), ' ', '') -- remove whitespace: ' ' and crlf
        =
            replace(replace(P.SqlStatement, CHAR(13) + CHAR(10), ''), ' ', '') -- remove whitespace: ' ' and crlf
-------------------------------------------------------------------------------
select top 1
    GroupRef = @testGroupRef,
    TargetTable = @testTargetTable
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
