declare @Creator nvarchar(128) = suser_sname()

SELECT
    ChangeCount = count(*),
    Created = CAST(MV.Created AS DATE),
    DBObjects = string_agg(M.Name, ', ')
FROM
    dbo.stbl_WebSiteCMS_ModulesVersions AS [MV] WITH (NOLOCK)
    join dbo.stbl_WebSiteCMS_Modules AS [M] WITH (NOLOCK) 
        on M.PrimKey = MV.ModuleRef
WHERE
    MV.CreatedBy = @Creator
    AND MV.Created > DATEADD(MONTH, -1, GETDATE())
GROUP BY
    CAST(MV.Created AS DATE)
ORDER BY
    Created DESC
