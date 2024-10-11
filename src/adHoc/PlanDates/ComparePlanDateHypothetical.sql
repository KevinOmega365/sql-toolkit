/*
 * Compare plan date hypothetical
 */
-- Using dcs_step instead of plan date

        SELECT -- 32,769
            DCS_Domain,
            DCS_DocumentID,
            ReasonForIssue,
            INTEGR_REC_BATCHREF,
            INTEGR_REC_GROUPREF
        FROM
            (

                    SELECT
                        DCS_Domain,
                        DCS_DocumentID,
                        ReasonForIssue = json_value(AI.value, '$.reasonForIssue'),
                        IssueDate = json_value(AI.value, '$.issueDate'),
                        INTEGR_REC_BATCHREF,
                        INTEGR_REC_GROUPREF
                    FROM
                        dbo.ltbl_Import_DTS_DCS_Documents D WITH (NOLOCK)
                        CROSS APPLY openjson(actualIssues) AI
                    -- WHERE
                    --     DCS_Domain IS NOT NULL

                UNION ALL

                    SELECT
                        DCS_Domain,
                        DCS_DocumentID,
                        ReasonForIssue = json_value(FI.value, '$.reasonForIssue'),
                        IssueDate = json_value(FI.value, '$.issueDate'),
                        INTEGR_REC_BATCHREF,
                        INTEGR_REC_GROUPREF
                    FROM
                        dbo.ltbl_Import_DTS_DCS_Documents D WITH (NOLOCK)
                        CROSS APPLY openjson(forecastIssues) FI
                    -- WHERE
                    --     DCS_Domain IS NOT NULL

                UNION ALL

                    SELECT
                        DCS_Domain,
                        DCS_DocumentID,
                        ReasonForIssue = json_value(PI.value, '$.reasonForIssue'),
                        IssueDate = json_value(PI.value, '$.issueDate'),
                        INTEGR_REC_BATCHREF,
                        INTEGR_REC_GROUPREF
                    FROM
                        dbo.ltbl_Import_DTS_DCS_Documents D WITH (NOLOCK)
                        CROSS APPLY openjson(plannedIssues) PI
                    -- WHERE
                    --     DCS_Domain IS NOT NULL
                        
            ) T
        GROUP BY
            DCS_Domain,
            DCS_DocumentID,
            ReasonForIssue,
            INTEGR_REC_BATCHREF,
            INTEGR_REC_GROUPREF