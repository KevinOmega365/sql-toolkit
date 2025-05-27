
DECLARE @GroupRef UNIQUEIDENTIFIER = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'
DECLARE @BatchRef UNIQUEIDENTIFIER = 'e2378789-dfeb-44b8-b017-85e409341cc9'
DECLARE @TableName NVARCHAR(128) = 'ltbl_Import_DTS_DCS_Documents'

DROP TABLE IF EXISTS #temp_mappings;

CREATE TABLE #temp_mappings (
    PriorityOrder INT,
    MappingSetID NVARCHAR(128),
    TargetTable NVARCHAR(128),
    CriteriaField1 NVARCHAR(128),
    CriteriaValue1 NVARCHAR(128),
    CriteriaField2 NVARCHAR(128),
    CriteriaValue2 NVARCHAR(128),
    FromField NVARCHAR(128),
    FromValue NVARCHAR(128),
    ToField NVARCHAR(128),
    ToValue NVARCHAR(128),
    MappingType NVARCHAR(128),
    Required BIT
);

/* make the sql table */

DROP TABLE IF EXISTS #temp_mappingSQLs;

CREATE TABLE #temp_mappingSQLs (
    PriorityOrder INT,
    MappingSetID NVARCHAR(128),
    MappingType  NVARCHAR(128),
    mappingSetJson NVARCHAR(MAX),
    sqlStatement NVARCHAR(MAX),
    statementExecuted BIT DEFAULT 0
);


INSERT INTO
    #temp_mappings (
        PriorityOrder,
        MappingSetID,
        TargetTable,
        CriteriaField1,
        CriteriaValue1,
        CriteriaField2,
        CriteriaValue2,
        FromField,
        FromValue,
        ToField,
        ToValue,
        MappingType,
        Required
    )
SELECT
    MS.PriorityOrder,
    MS.MappingSetID,
    S.TargetTable,
    S.CriteriaField1,
    V.CriteriaValue1,
    S.CriteriaField2,
    V.CriteriaValue2,
    S.FromField,
    V.FromValue,
    S.ToField,
    V.ToValue,
    V.MappingType,
    S.Required
FROM
    [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] AS S WITH (NOLOCK)
    INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] AS V WITH (NOLOCK)
        ON V.MappingSetID = S.MappingSetID
    INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets] AS MS WITH (NOLOCK)
        ON MS.MappingSetID = V.MappingSetID
WHERE
    S.GroupRef = @GroupRef
    AND S.TargetTable = @TableName
ORDER BY
    MS.PriorityOrder,
    MS.MappingSetID

INSERT INTO #temp_mappingSQLs (
    PriorityOrder,
    MappingSetID,
    MappingType,
    mappingSetJson
)
SELECT
    PriorityOrder,
    MappingSetID,
    MappingType,
    MappingJson = (
        SELECT
            PriorityOrder,
            MappingSetID,
            TargetTable,
            CriteriaField1,
            CriteriaValue1,
            CriteriaField2,
            CriteriaValue2,
            FromField,
            FromValue,
            ToField,
            ToValue,
            MappingType,
            Required
        FROM
            #temp_mappings J
        WHERE
            J.MappingSetID = M.MappingSetID
        FOR JSON
            PATH
    )
FROM
    #temp_mappings M
GROUP BY
    PriorityOrder,
    MappingSetID,
    MappingType

UPDATE
    #temp_mappingSQLs
SET sqlStatement =[dbo].[lfnc_Import_DTS_DCS_FieldMappings_GetSql] (
    @BatchRef,
    MappingType,
    MappingSetJson
)

SELECT sqlStatement
FROM #temp_mappingSQLs