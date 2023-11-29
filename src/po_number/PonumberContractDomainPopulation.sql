
/**
 * From XLSL dump
 */
declare @PONumberDescriptions table 
(
    PONumber nvarchar(max),
    Description nvarchar(max)
)
insert into @PONumberDescriptions
values
    ('PACKAGE_NUMBER', 'DESCRIPTION') -- , ...

-------------------------------------------------------------------------------

DECLARE @ValidDomains TABLE
(
    Domain NVARCHAR(128)
)
insert into @ValidDomains
values
    ('145'),
    ('128'),
    ('187'),
    ('153')

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
    Domain = DCS_Domain,
    PONumber = DCS_PONumber,
    Description = COALESCE(PONumberDescriptions.Description, 'TBD'),
    CompanyID = 'Aker Solut'
FROM
    [dbo].[ltbl_Import_ProArc_Documents] AS D WITH (NOLOCK)
    LEFT JOIN @PONumberDescriptions PONumberDescriptions
        ON D.DCS_PONumber = PONumberDescriptions.PONumber
WHERE
    DCS_Domain IN (SELECT * FROM @ValidDomains)
    AND DCS_PONumber IS NOT NULL
    AND DCS_ContractNo IS NOT NULL

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
    Domain = DCS_Domain,
    PONumber = DCS_PONumber,
    Description = COALESCE(PONumberDescriptions.Description, 'TBD'),
    CompanyID = 'Aker Solut',
    ContractNumber = DCS_ContractNo
FROM
    [dbo].[ltbl_Import_ProArc_Documents] AS D WITH (NOLOCK)
    LEFT JOIN @PONumberDescriptions PONumberDescriptions
        ON D.DCS_PONumber = PONumberDescriptions.PONumber
WHERE
    DCS_Domain IN (SELECT * FROM @ValidDomains)
    AND DCS_PONumber IS NOT NULL
    AND DCS_ContractNo IS NOT NULL
