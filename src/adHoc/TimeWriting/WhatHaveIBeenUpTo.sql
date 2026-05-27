
-- Users > User Details > Logs > Web Activity Logs

DECLARE @CreatedBy NVARCHAR(128) = SUSER_SNAME()
DECLARE @FromDate DATE = DATEADD(MONTH, -1, GETDATE())

/*
 * recent actitiviy for user (COUNT)
 */
SELECT
    COUNT(*) AS [Count],
    [Domain],
    [ArticleId]
FROM
    dbo.stbl_WebSiteCMS_Log WITH (NOLOCK)
WHERE
    CreatedBy = @CreatedBy
    AND Created > @FromDate
    AND Action NOT LIKE 'Email token confirmation sent to%'
GROUP BY
    [Domain],
    [ArticleId]
ORDER BY
    COUNT(*) DESC

/*
 * recent actitiviy for user (ROLLUP)
 */
-- SELECT
--     COUNT(*) AS [Count],
--     [Domain],
--     [ArticleId]
-- FROM
--     dbo.stbl_WebSiteCMS_Log WITH (NOLOCK)
-- WHERE
--     CreatedBy = @CreatedBy
--     AND Created > @FromDate
--     AND Action NOT LIKE 'Email token confirmation sent to%'
-- GROUP BY ROLLUP (
--     [Domain],
--     [ArticleId]
-- )

/*
 * recent actitiviy for user (CUBE)
 */
-- SELECT
--     COUNT(*) AS [Count],
--     [Domain],
--     [ArticleId]
-- FROM
--     dbo.stbl_WebSiteCMS_Log WITH (NOLOCK)
-- WHERE
--     CreatedBy = @CreatedBy
--     AND Created > @FromDate
--     AND Action NOT LIKE 'Email token confirmation sent to%'
-- GROUP BY CUBE (
--     [Domain],
--     [ArticleId]
-- )

/*
 * recent actitiviy for user (SAMPLE)
 */
-- SELECT TOP 50
--     [AutoID],
--     [PrimKey],
--     [Created],
--     [CreatedBy],
--     [Updated],
--     [UpdatedBy],
--     [CUT],
--     [CDL],
--     [Domain],
--     [HostName],
--     [Action],
--     [ArticleId],
--     [Datasource],
--     [Filter],
--     [WhereClause],
--     [MaxRecords],
--     [OrderBy],
--     [LinkValues],
--     [RecordCount],
--     [TimeElapsed],
--     [SessionId],
--     [URL],
--     [Parameters],
--     [UserAgent],
--     [ClientIP]
-- FROM
--     dbo.stbl_WebSiteCMS_Log WITH (NOLOCK)
-- WHERE
--     CreatedBy = @CreatedBy
-- ORDER BY
--     Created DESC
