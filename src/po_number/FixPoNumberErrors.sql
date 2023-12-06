-------------------------------------------------------------------------------
-------------------- Add missing PO Numbers to DCS Config from Import Errors --
-------------------------------------------------------------------------------

DECLARE
    @ErrorPattern NVARCHAR(MAX) = '%The provided PONumber is not valid for this Contract No%',
    @DefaultDescription NVARCHAR(MAX) = 'TBD',
    @DefaultCompanyID NVARCHAR(MAX) = 'Aker Solut'

/**
 * Contracts and PO Numbers from Import Errors
 */
DECLARE @DomainsContractNoPoNumbers TABLE 
(
    Domain NVARCHAR(128),
    ContractNo NVARCHAR(MAX),
    PONumber NVARCHAR(MAX)
)
INSERT INTO @DomainsContractNoPoNumbers
SELECT DISTINCT
    DCS_Domain,
    DCS_ContractNo,
    DCS_PONumber
FROM
    dbo.ltbl_Import_ProArc_Documents WITH (NOLOCK)
WHERE
    INTEGR_REC_ERROR LIKE @ErrorPattern

-------------------------------------------------------------------------------

/**
 * Purchase Orders
 */
-- INSERT INTO [dbo].[atbl_DCS_PurchaseOrders]
-- (
--     Domain,
--     PONumber,
--     Description,
--     CompanyID
-- )
SELECT DISTINCT
    Domain = Domain,
    PONumber = PONumber,
    Description = @DefaultDescription,
    CompanyID = @DefaultCompanyID
FROM
    @DomainsContractNoPoNumbers ToBeAdded
WHERE
    NOT EXISTS (
        SELECT *
        FROM [dbo].[atbl_DCS_PurchaseOrders] Existing WITH (NOLOCK)
        WHERE
                Existing.Domain = ToBeAdded.Domain
                AND Existing.PONumber = ToBeAdded.PONumber
                AND Existing.Description = @DefaultDescription
                AND Existing.CompanyID = @DefaultCompanyID
    )

-------------------------------------------------------------------------------

/**
 * Contracts Purchase Orders
 */
-- INSERT INTO [dbo].[atbl_DCS_ContractsPurchaseOrders]
-- (
--     Domain,
--     PONumber,
--     Description,
--     CompanyID,
--     ContractNumber
-- )
SELECT DISTINCT
    Domain,
    PONumber,
    Description = @DefaultDescription,
    CompanyID = @DefaultCompanyID,
    ContractNumber = ContractNo
FROM
    @DomainsContractNoPoNumbers ToBeAdded
WHERE
    NOT EXISTS (
        SELECT *
        FROM [dbo].[atbl_DCS_ContractsPurchaseOrders] Existing WITH (NOLOCK)
        WHERE
                Existing.Domain = ToBeAdded.Domain
                AND Existing.PONumber = ToBeAdded.PONumber
                AND Existing.Description = @DefaultDescription
                AND Existing.CompanyID = @DefaultCompanyID
                AND Existing.ContractNumber = ToBeAdded.ContractNo
    )