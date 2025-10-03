
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

declare @MappingApplications table (
    GroupRef uniqueidentifier,
    TargetTable nvarchar(128)
)

insert into @MappingApplications
(
    GroupRef,
    TargetTable
)
select
    GroupRef,
    TargetTable
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
group by
    GroupRef,
    TargetTable

-- select * from @MappingApplications -- debug

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

declare @FunctionGenerated table (
    GroupRef uniqueidentifier,
    MappingSetID nvarchar(128),
    TableName NVARCHAR(128),
    SqlStatement nvarchar(max)
)

declare @ProcedureGenerated table (
    SqlStatement NVARCHAR(MAX),
    GroupRef UNIQUEIDENTIFIER,
    TableName NVARCHAR(128),
    MappingSetID NVARCHAR(128)
)

/*
 *  todo: loopity-loop <- here
 */
while exists(
    select *
    from @MappingApplications
)
begin

    ---------------------------------------------------------------------------

    select top 1
        @testGroupRef = GroupRef,
        @testTargetTable = TargetTable
    from
        @MappingApplications

    ---------------------------------------------------------------------------

    insert into @FunctionGenerated (
        GroupRef,
        MappingSetID,
        TableName,
        SqlStatement
    )
    SELECT
        GroupRef,
        MappingSetID,
        TargetTable,
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
                TargetTable,
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
                    FROM
                        dbo.aviw_Integrations_Configurations_FieldMappingSets_GroupFieldMappings Mapping
                    WHERE
                        Mapping.GroupRef = PipelineMappings.GroupRef
                        AND Mapping.MappingSetID = PipelineMappings.MappingSetID
                        AND Mapping.TargetTable = PipelineMappings.TargetTable
                        AND Mapping.FromField = PipelineMappings.FromField
                        AND Mapping.ToField = PipelineMappings.ToField
                    FOR JSON
                        AUTO
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

    ---------------------------------------------------------------------------

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

    ---------------------------------------------------------------------------

    delete @MappingApplications
    where
        GroupRef = @testGroupRef
        and TargetTable = @testTargetTable

    ---------------------------------------------------------------------------

end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

/*
 * do a full outer join to match the sql
 * work toward whitespace removal
 */
select distinct
    FunctionalSql,
    ProceduralSql
from
(
    select
        FunctionalGroupRef = F.GroupRef,
        FunctionalMappingSetID = F.MappingSetID,
        FunctionalSql = F.SqlStatement,
        ProceduralSql = P.SqlStatement,
        FunctionalSqlStripped = replace(replace(F.SqlStatement, CHAR(13) + CHAR(10), ''), ' ', ''), -- remove whitespace: ' ' and crlf
        ProceduralSqlStripped = replace(replace(P.SqlStatement, CHAR(13) + CHAR(10), ''), ' ', ''), -- remove whitespace: ' ' and crlf
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
) T
-- where
--     FunctionalSqlStripped <> ProceduralSqlStripped

select distinct SqlStatement from @ProcedureGenerated P
select distinct SqlStatement from @FunctionGenerated F
