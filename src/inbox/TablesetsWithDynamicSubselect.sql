/**
 * Table set with
 *   latest batch ref
 *   max Created
 *
 *   optional filter on GroupRef
 *
 *   tables in set need INTEGR_REC_GROUPREF
 */
DECLARE
    @TableSetPK UNIQUEIDENTIFIER = 'ede47ca0-0f44-46f7-804d-932ee4704365', --'6be12657-418f-4927-ba95-e1ce8362944d'
    @GroupRefString NVARCHAR(36) = '%',
    @SqlStatement NVARCHAR(MAX)

SELECT @SqlStatement = STRING_AGG(CAST(SqlClause AS NVARCHAR(MAX)), ' UNION ALL ') WITHIN GROUP (ORDER BY SortOrder, Name)
FROM
(
    SELECT
        Name,
        SortOrder,
        SqlClause = '
            SELECT
                TableSetID,
                TableSetDescription,
                GeneratedDSId,
                DBObjectID,
                Name,
                PrimKey,
                WhereClause,
                ApplyGroupRefFilter,
                ExcludeFromGlobalSearch,
                LatestBatchRef = (SELECT TOP 1 INTEGR_REC_BATCHREF FROM dbo.' + DBObjectID + ' WHERE INTEGR_REC_GROUPREF like ''' + @GroupRefString + ''' ORDER BY Created DESC),
                LatestBatchTS = (SELECT MAX(Created) FROM dbo.' + DBObjectID + ' WHERE INTEGR_REC_GROUPREF like ''' + @GroupRefString + '''),
                SortOrder
            FROM
                [dbo].[aviw_Integrations_TableSets_Tables]
            WHERE
                PrimKey = ''' + CAST(PrimKey AS NVARCHAR(36)) + ''''
    FROM
        [dbo].[aviw_Integrations_TableSets_Tables]
    WHERE
        TableSetPK = @TableSetPK
        AND Inactive = 0
        AND EXISTS ( -- needed this to ensure tables have INTEGR_REC_GROUPREF
            SELECT *
            FROM sys.columns C
            WHERE
                C.object_id = OBJECT_ID(DBObjectID)
                AND C.name = 'INTEGR_REC_GROUPREF'
        )
) T

EXEC sp_executesql @SqlStatement

/**
 * Tables without INTEGR_REC_GROUPREF
 */
-- SELECT
--     DBObjectID
-- FROM
--     [dbo].[aviw_Integrations_TableSets_Tables]
-- WHERE
--     TableSetPK = @TableSetPK
--     AND Inactive = 0
--     AND NOT EXISTS ( -- needed this for 
--         SELECT *
--         FROM sys.columns C
--         WHERE
--             C.object_id = OBJECT_ID(DBObjectID)
--             AND C.name = 'INTEGR_REC_GROUPREF'
--     )