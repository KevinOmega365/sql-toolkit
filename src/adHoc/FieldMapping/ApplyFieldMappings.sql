-- CREATE OR ALTER PROC [dbo].[lstp_Import_DTS_DCS_ApplyFieldMappings](
declare
    @GroupRef UNIQUEIDENTIFIER = '8eea5c84-1cb6-4c95-9f16-b22de8764d3a',
    @BatchRef UNIQUEIDENTIFIER = newid(),
    @TableName NVARCHAR(128) = 'ltbl_Import_AKSO_Mips_BoltCon'
-- )
-- AS
-- BEGIN
    -- BEGIN TRY
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

        DROP TABLE IF EXISTS #temp_MappingValues;

        SELECT NEWID() AS ID, S.TargetTable, S.CriteriaField1,S.CriteriaField2,S.FromField,S.ToField, S.Required, V.CriteriaValue1, V.CriteriaValue2, V.FromValue, V.ToValue, 0 AS ProcessStep
		INTO #temp_MappingValues
        FROM [dbo].[atbv_Integrations_Configurations_FieldMappingSets_Subscribers] AS S WITH (NOLOCK)
        INNER JOIN [dbo].[atbv_Integrations_Configurations_FieldMappingSets_Values] AS V WITH (NOLOCK)
        ON V.MappingSetID = S.MappingSetID
        WHERE S.GroupRef = @GroupRef AND S.TargetTable = @TableName


        DECLARE @targetTable AS NVARCHAR(128)
        DECLARE @targetField AS NVARCHAR(128)
        DECLARE @value AS NVARCHAR(MAX)

        DECLARE @criteriaField1 AS NVARCHAR(128) = NULL
        DECLARE @criteriaField2 AS NVARCHAR(128) = NULL
        DECLARE @fromField AS NVARCHAR(128)
        DECLARE @toField AS NVARCHAR(128)
        DECLARE @criteriaValue1 AS NVARCHAR(MAX) = NULL
        DECLARE @criteriaValue2 AS NVARCHAR(MAX) = NULL

        DECLARE @fromValue AS NVARCHAR(MAX)
        DECLARE @toValue AS NVARCHAR(MAX)

        WHILE EXISTS (SELECT TOP 1 1 FROM #temp_MappingValues WITH (NOLOCK) WHERE ProcessStep=0)
        BEGIN
            SELECT TOP 1 @currentID=[ID], @targetTable=[TargetTable], @criteriaField1=[CriteriaField1], @criteriaField2=[CriteriaField2], @criteriaValue1=[CriteriaValue1], @criteriaValue2=[CriteriaValue2], @fromField=[FromField],@toField=[ToField], @fromValue=[FromValue], @toValue=[ToValue]
			FROM #temp_MappingValues WITH (NOLOCK)
			WHERE [ProcessStep] = 0;

            SET @sql = 'UPDATE [dbo].[' + @targetTable + '] SET [' + @toField + ']=''' + @toValue + ''' WHERE [INTEGR_REC_BATCHREF]=''' + CAST(@BatchRef AS NVARCHAR(128)) + ''' AND [INTEGR_REC_STATUS]=''' + @IMPORTED_OK + ''''
                       + ' AND [' + @fromField + '] = ''' + @fromValue + ''' ';


            IF ISNULL(@criteriaField1,'') <>'' AND ISNULL(@criteriaValue1,'') <> ''
            BEGIN
                SET @sql = @sql + ' AND [' + @criteriaField1 + '] = ''' + @criteriaValue1 + ''' ';
            END

            IF ISNULL(@criteriaField2,'') <>'' AND ISNULL(@criteriaValue2,'') <> ''
            BEGIN
                SET @sql = @sql + ' AND [' + @criteriaField2 + '] = ''' + @criteriaValue2 + ''' '
            END

            PRINT @sql
            --EXECUTE sp_executesql @sql; --QAIgnore

            UPDATE #temp_MappingValues SET [ProcessStep] = 1 WHERE [ID] = @currentID;
        END

        -- VALIDATE REQUIRED MAPPINGS - set to Out of Scope if no mapping value was found
        UPDATE #temp_MappingValues SET [ProcessStep] = 0;
        WHILE EXISTS (SELECT TOP 1 1 FROM #temp_MappingValues WITH (NOLOCK) WHERE [ProcessStep]=0 AND [Required] = 1)
        BEGIN
            SELECT TOP 1 @currentID=[ID], @targetTable=[TargetTable], @fromField=[FromField], @toField=[ToField]  FROM #temp_MappingValues WITH (NOLOCK) WHERE [ProcessStep] = 0 AND [Required] = 1;

            SET @sql = 'UPDATE [dbo].[' + @targetTable + '] SET [INTEGR_REC_STATUS]=''' + @OUT_OF_SCOPE + ''', '
                     + ' [INTEGR_REC_TRACE]=JSON_MODIFY(ISNULL(NULLIF([INTEGR_REC_TRACE], ''''), ''' + @traceBase + '''),''append $.scope'',''Failed to find a value for ' + @fromField + ' in field mapping set'') '
                     + ' WHERE [INTEGR_REC_BATCHREF]=''' + CAST(@BatchRef AS NVARCHAR(128)) + ''' AND [INTEGR_REC_STATUS]=''' + @IMPORTED_OK + ''' '
            SET @sql = @sql + ' AND ISNULL([' + @toField + '],'''') = ''''';

            PRINT @sql
            -- EXECUTE sp_executesql @sql; --QAIgnore

            UPDATE #temp_MappingValues SET [ProcessStep] = 1  WHERE [ID] = @currentID AND [Required] = 1;
        END
    -- END TRY
    -- BEGIN CATCH
    --     RAISERROR('Applying field mappings failed!',18,1)
    --     RETURN
    -- END CATCH
-- END
