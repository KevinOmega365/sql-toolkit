
/*
 * working table of single JSON records
 */
DROP TABLE IF EXISTS #JsonRows DECLARE @ListGroupID INT = 1
SELECT
    SourceJSON = VALUE,
    PrimKey = NEWID()
INTO
    #JsonRows
FROM
    dbo.ltbl_Import_SharePointList_OnboardingListItems_RAW WITH (NOLOCK)
    CROSS APPLY OPENJSON (JSON_DATA, '$.value')

/*
 * count of person IDs in the person-project table
 */
SELECT
    COUNT(DISTINCT ID)
FROM
    dbo.ltbl_Import_SharePointList_OnboardingListItems_SingleProjectLine WITH (NOLOCK)

/*
 * expected number of single-project-line rows
 */
SELECT
    SUM(PersonProjectCount)
FROM
    (
        SELECT
            PersonProjectCount = (
                SELECT
                    COUNT(*)
                FROM
                    OPENJSON (JSON_QUERY(SourceJSON, '$.fields.Project'))
            )
        FROM
            #JsonRows
    ) T

/*
 * quick random sample
 */
SELECT
    TOP 10 PersonProjectCount = (
        SELECT
            COUNT(*)
        FROM
            OPENJSON (JSON_QUERY(SourceJSON, '$.fields.Project'))
    )
FROM
    #JsonRows
ORDER BY
    NEWID()

/*
 * number of rows in working table (should match: count of person IDs in the
 * person-project table )
 */
SELECT
    COUNT(*)
FROM
    #JsonRows

/*
 * Rollup from the current solution (the count for list group 1 where the
 * persons have not been removed from the source should match the #JsonRows
 * count and count of person IDs in the person-project table)
 */
SELECT
    SharepointListGroupId,
    IsRemovedFromSource,
    RecordCount = COUNT(*)
FROM
    dbo.ltbl_Import_SharePointList_OnboardingListItems WITH (NOLOCK)
GROUP BY
    ROLLUP (SharepointListGroupId, IsRemovedFromSource)
