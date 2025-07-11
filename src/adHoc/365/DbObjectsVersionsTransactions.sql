
/*
 * Transactions
 */
SELECT *
FROM
    dbo.stbl_Deploy_Transactions
WHERE
    Name LIKE '%astp[_]tge[_]%'

/*
 * Vesions
 */
SELECT *
FROM
    dbo.stbl_Database_Versions
WHERE
    DBObjectID LIKE '%_Tge_%'

/*
 * Objects
 */
SELECT
    DBObjectID
FROM
    dbo.stbl_Database_Objects
WHERE
    DBObjectID LIKE '%Tge[_]AzureAd%'

/*
 * Procedure object definitions
 */
SELECT
    ProcedureName = P.Name,
    ProcedureSource = object_definition(object_id)
FROM
    sys.objects P
WHERE
    P.name LIKE 'astp_TGE_AzureAd%'
    AND P.type IN ('p')
ORDER BY
    ProcedureName
