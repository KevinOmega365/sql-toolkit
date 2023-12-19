
/**
 * Usage of PO Number / Package across import domains by document group
 */

DECLARE @FilterDomain NVARCHAR(128) = '181' -- '175' -- '%'

DECLARE @OUT_OF_SCOPE AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='OUT_OF_SCOPE')

----------------------------------------------------- document group coverage --
SELECT
    InstanceCount = COUNT(*),
    Domain = DCS_Domain,
    HasPoNumber = CASE
        WHEN package IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    DocumentGroup = DCS_DocumentGroup
FROM
    dbo.ltbl_Import_ProArc_Documents WITH (NOLOCK)
WHERE
    DCS_Domain like @FilterDomain
    AND INTEGR_REC_STATUS <> @OUT_OF_SCOPE
GROUP BY
    DCS_Domain,
    CASE
        WHEN package IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    DCS_DocumentGroup

UNION ALL

SELECT
    InstanceCount = COUNT(*),
    Domain = DCS_Domain,
    HasPoNumber = CASE
        WHEN purchaseOrderNumber IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    DocumentGroup = documentGroup
FROM
    dbo.ltbl_Import_MuninAibel_Documents WITH (NOLOCK)
WHERE
    DCS_Domain like @FilterDomain
    AND INTEGR_REC_STATUS <> @OUT_OF_SCOPE
GROUP BY
    DCS_Domain,
    CASE
        WHEN purchaseOrderNumber IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    documentGroup

ORDER BY
    Domain,
    DocumentGroup

------------------------------------------------------------ per po / package --
SELECT
    InstanceCount = COUNT(*),
    Domain = DCS_Domain,
    PO = package,
    DocumentGroup = document_group
FROM
    dbo.ltbl_Import_ProArc_Documents WITH (NOLOCK)
WHERE
    DCS_Domain like @FilterDomain
    AND INTEGR_REC_STATUS <> @OUT_OF_SCOPE
GROUP BY
    DCS_Domain,
    package,
    document_group
UNION ALL
SELECT
    InstanceCount = COUNT(*),
    DOMAIN = DCS_Domain,
    PO = purchaseOrderNumber,
    DocumentGroup = documentGroup
FROM
    dbo.ltbl_Import_MuninAibel_Documents WITH (NOLOCK)
WHERE
    DCS_Domain like @FilterDomain
    AND INTEGR_REC_STATUS <> @OUT_OF_SCOPE
GROUP BY
    DCS_Domain,
    purchaseOrderNumber,
    documentGroup

ORDER BY
    Domain,
    DocumentGroup,
    PO