/**
 * Chain logic vs steps (MuninAibel)
 */
-- SELECT TOP 25
--     DCS_Step_CurrentLogic = R.reasonForIssue,
--     DCS_Step_NewLogic = (
--         SELECT Step =
--             CASE
--                 WHEN isnull(D.DCS_Criticality, '') = 'SafetyCritical' THEN C.PriorityOneStep
--                 WHEN isnull(R.reasonForIssue, '') = 'IFR' THEN C.PriorityTwoStep
--                 ELSE C.DefaultStep
--             END
--         FROM
--             dbo.ltbl_Import_Mapping_ProArcChains AS C WITH (NOLOCK)
--         WHERE
--             C.GroupRef = D.INTEGR_REC_GROUPREF
--             AND C.Domain = D.DCS_Domain
--             AND C.Chain = D.chain
--             AND C.ReasonForIssue = R.reasonForIssue
--     ),
--     D.INTEGR_REC_GROUPREF,
--     D.DCS_Domain,
--     D.chain,
--     R.reasonForIssue,
--     D.DCS_Criticality
-- FROM
--     dbo.ltbl_Import_MuninAibel_Documents D WITH (NOLOCK)
--     JOIN dbo.ltbl_Import_MuninAibel_Revisions R WITH (NOLOCK)
--         ON R.DCS_Domain = D.DCS_Domain
--         AND R.DCS_DocumentID = D.DCS_DocumentID
--         AND R.INTEGR_REC_BATCHREF = D.INTEGR_REC_BATCHREF
-- WHERE
--     chain is not null
-- ORDER BY
--     NEWID()

/**
 * Chain data coverage (MuninAibel)
 */
-- SELECT
--     InstanceCount = count(*),
--     Domain = DCS_Domain,
--     Chain
-- FROM
--     dbo.ltbl_Import_MuninAibel_Documents D WITH (NOLOCK)
-- GROUP BY
--     DCS_Domain,
--     Chain
-- ORDER BY
--     DCS_Domain, 
--     Chain

/**
 * Chain instance count by domain (MuninAibel)
 */
-- SELECT
--     InstanceCount = count(*),
--     Domain,
--     HasChain
-- FROM
-- (
--     SELECT
--         Domain = DCS_Domain,
--         HasChain = cast(case when Chain is null then 0 else 1 end as bit)
--     FROM
--         dbo.ltbl_Import_MuninAibel_Documents D WITH (NOLOCK)
-- ) T
-- GROUP BY
--     Domain,
--     HasChain
-- ORDER BY
--     InstanceCount desc

/**
 * Chain instance count by domain (ProArc)
 */
-- SELECT
--     InstanceCount = count(*),
--     Domain,
--     HasChain
-- FROM
-- (
--     SELECT
--         Domain = DCS_Domain,
--         HasChain = cast(case when Chain is null then 0 else 1 end as bit)
--     FROM
--         dbo.ltbl_Import_ProArc_Documents D WITH (NOLOCK)
-- ) T
-- GROUP BY
--     Domain,
--     HasChain
-- ORDER BY
--     InstanceCount desc