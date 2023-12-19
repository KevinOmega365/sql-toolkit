
/**
 * Usage of PO Number / Package across import domains by document group
 */

DECLARE @FilterDomain NVARCHAR(128) = '181' -- '%'

----------------------------------------------------- document group coverage --
SELECT
    InstanceCount = COUNT(*),
    DOMAIN = DCS_Domain,
    HasPoNumber = CASE
        WHEN package IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    DocumentGroup = DCS_DocumentGroup
FROM
    dbo.ltbl_Import_ProArc_Documents WITH (NOLOCK)
WHERE
    DCS_Domain = @FilterDomain
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
    DOMAIN = DCS_Domain,
    HasPoNumber = CASE
        WHEN purchaseOrderNumber IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    DocumentGroup = documentGroup
FROM
    dbo.ltbl_Import_MuninAibel_Documents WITH (NOLOCK)
WHERE
    DCS_Domain = @FilterDomain
GROUP BY
    DCS_Domain,
    CASE
        WHEN purchaseOrderNumber IS NOT NULL
        THEN 'YES'
        ELSE ''
    END,
    documentGroup

------------------------------------------------------------ per po / package --
SELECT
    InstanceCount = COUNT(*),
    DOMAIN = DCS_Domain,
    PO = package,
    DocumentGroup = document_group
FROM
    dbo.ltbl_Import_ProArc_Documents WITH (NOLOCK)
WHERE
    DCS_Domain = @FilterDomain
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
    DCS_Domain = @FilterDomain
GROUP BY
    DCS_Domain,
    purchaseOrderNumber,
    documentGroup