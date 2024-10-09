,
        DocExistsInDCS = CASE
            WHEN D.DocumentID IS NULL THEN 0
            ELSE 1
            END,
        IntegrationRecordStatus = COALESCE
            (
                (
                    SELECT Status
                    FROM dbo.atbl_Integrations_ImportStatuses S WITH (NOLOCK)
                    WHERE S.ID = T.INTEGR_REC_STATUS
                ),
                T.INTEGR_REC_STATUS
            )
    FROM
        dbo.{{YOUR_TABLE_HERE}} AS T WITH(NOLOCK)
        LEFT JOIN [dbo].[atbl_DCS_Documents] AS D WITH (NOLOCK)
            ON D.[Domain] = T.[DCS_Domain]
            AND D.[DocumentID] = T.[DCS_DocumentID]