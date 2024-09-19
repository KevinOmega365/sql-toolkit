-- CREATE OR ALTER PROC [dbo].[astp_Integrations_Configurations_ApplyFieldMappings](
declare
	@GroupRef UNIQUEIDENTIFIER = '3f40f2bd-5eb3-42f3-8e6a-4fb5691fd496',
    @BatchRef UNIQUEIDENTIFIER = '6958840d-77b4-4486-827e-83a8dfb651d9',
	@TableName NVARCHAR(128) = 'ltbl_Import_AKSO_Mips_JobFile'
-- )
-- AS
BEGIN
	BEGIN TRY
        DECLARE @IMPORTED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='IMPORTED_OK')                 -- Transition in/out
        DECLARE @OUT_OF_SCOPE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='OUT_OF_SCOPE')               -- Final

        IF @IMPORTED_OK IS NULL OR @OUT_OF_SCOPE IS NULL
        BEGIN
            RAISERROR('INTEGR_REC_STATUS not found in atbl_Integrations_ImportStatuses',18,1)
            RETURN
        END

        DECLARE @sql NVARCHAR(MAX)
        DECLARE @currentID AS UNIQUEIDENTIFIER

		DECLARE @traceBase nvarchar(max) = '{"scope": []}';		

        DECLARE @temp_mappingSQLs TABLE (
            ID uniqueidentifier DEFAULT NEWID()
            , sqlStatement NVARCHAR(MAX)
            , statementExecuted BIT  DEFAULT 0          
        );

        DECLARE @temp_requiredCheckSQLs TABLE (
            ID uniqueidentifier DEFAULT NEWID()
            , sqlStatement NVARCHAR(MAX)
            , statementExecuted BIT DEFAULT 0          
        );

        -- generate mapping sqls
        INSERT INTO @temp_mappingSQLs (sqlStatement)
        SELECT A.S1 + A.S2 + A.S3 + A.C1 + A.C2
        FROM (
            SELECT TOP 10000 ''
                        + 'UPDATE [dbo].[' + S.TargetTable + ']' AS S1,
                    CASE WHEN V.MappingType='Set Null' THEN        
                          ' SET [' + S.ToField + '] = NULL '
                    ELSE
                          ' SET [' + S.ToField + '] = ''' + V.ToValue + ''' ' 
                    END AS S2,
                          ' WHERE [INTEGR_REC_BATCHREF] = ''' + CAST(@BatchRef AS NVARCHAR(128)) + '''' 
                            + ' AND [INTEGR_REC_STATUS] = ''' + @IMPORTED_OK + '''' 
                            + ' AND [' + S.FromField + '] = ''' + V.FromValue + ''' ' AS S3,
                    CASE WHEN ISNULL(S.CriteriaField1,'') <> '' AND ISNULL(V.CriteriaValue1,'') <> '' THEN
                        ' AND [' + S.CriteriaField1 + '] = ''' + V.CriteriaValue1 + ''' ' ELSE ' ' END AS C1,
                    CASE WHEN ISNULL(S.CriteriaField2,'') <> '' AND ISNULL(V.CriteriaValue2,'') <> '' THEN
                        ' AND [' + S.CriteriaField2 + '] = ''' + V.CriteriaValue2 + ''' ' ELSE ' ' END AS C2
            FROM [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] AS S WITH (NOLOCK) 
            INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] AS V WITH (NOLOCK)
                ON V.MappingSetID = S.MappingSetID 
            INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets] AS MS WITH (NOLOCK)
                ON MS.MappingSetID = V.MappingSetID                 
            WHERE 
                S.GroupRef = @GroupRef 
                AND S.TargetTable = @TableName
            ORDER BY MS.PriorityOrder, MS.MappingSetID
        ) AS A;


        -- generate required sqls
        INSERT INTO @temp_requiredCheckSQLs (sqlStatement)
        SELECT ''
            + 'UPDATE [dbo].[' + S.TargetTable + ']'
                    + ' SET [INTEGR_REC_STATUS]=''' + @OUT_OF_SCOPE + ''', ' 
                        + ' [INTEGR_REC_TRACE]=JSON_MODIFY(ISNULL(NULLIF([INTEGR_REC_TRACE], ''''), ''' + @traceBase + '''),''append $.scope'',''Failed to find a value for ' + S.FromField + ' in field mapping set'') '
                    + ' WHERE [INTEGR_REC_BATCHREF]=''' + CAST(@BatchRef AS NVARCHAR(128)) + ''''
                        + ' AND [INTEGR_REC_STATUS]=''' + @IMPORTED_OK + ''' '
                        + ' AND ISNULL([' + S.ToField + '],'''') = '''''
        FROM [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Subscribers] AS S WITH (NOLOCK) 
        INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets_Values] AS V WITH (NOLOCK)
            ON V.MappingSetID = S.MappingSetID 
        INNER JOIN [dbo].[atbl_Integrations_Configurations_FieldMappingSets] AS MS WITH (NOLOCK)
            ON MS.MappingSetID = V.MappingSetID                    
        WHERE 
            S.GroupRef = @GroupRef 
            AND S.TargetTable = @TableName
            AND S.Required=1
        ORDER BY MS.PriorityOrder, MS.MappingSetID;

        SELECT * FROM @temp_mappingSQLs -- debug
        SELECT * FROM @temp_requiredCheckSQLs -- debug

/*

        -- EXECUTE MAPPINGS 
        WHILE EXISTS (SELECT TOP 1 1 FROM @temp_mappingSQLs WHERE [statementExecuted] = 0)         
		BEGIN
	        SELECT TOP 1 
                  @currentID=[ID]
                , @sql = [sqlStatement]
            FROM @temp_mappingSQLs 
            WHERE 
                [statementExecuted] = 0;

			PRINT @sql
			-- EXECUTE sp_executesql @sql; --QAIgnore

            UPDATE @temp_mappingSQLs SET [statementExecuted] = 1 WHERE [ID] = @currentID;
        END

        -- EXECUTE REQUIRED MAPPINGS CHECK - set to Out of Scope if no mapping value was found
        WHILE EXISTS (SELECT TOP 1 1 FROM @temp_requiredCheckSQLs WHERE [statementExecuted] = 0)         
		BEGIN
	        SELECT TOP 1 
                  @currentID=[ID]
                , @sql = [sqlStatement]
            FROM @temp_requiredCheckSQLs 
            WHERE 
                [statementExecuted] = 0;

			PRINT @sql
			-- EXECUTE sp_executesql @sql; --QAIgnore

            UPDATE @temp_requiredCheckSQLs SET [statementExecuted] = 1 WHERE [ID] = @currentID;
        END

*/

	END TRY
	BEGIN CATCH
        DECLARE @errmsg NVARCHAR(MAX)
        SET @errmsg = 'Applying field mappings failed! (' + ERROR_MESSAGE() + ')';
        RAISERROR(@errmsg,18,1) 
        RETURN
	END CATCH

END