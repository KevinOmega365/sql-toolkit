declare @Creator nvarchar(128) = N'a_kevin'
SELECT
    ChangeCount = count(*),
    Created = CAST(Created AS DATE),
    DBObjects = string_agg(DBObjectID, ', ')
FROM
    dbo.sviw_Database_Versions
WHERE
    CreatedBy = @Creator
    AND Created > DATEADD(MONTH, -1, GETDATE())
GROUP BY
    CAST(Created AS DATE)
ORDER BY
    Created DESC
