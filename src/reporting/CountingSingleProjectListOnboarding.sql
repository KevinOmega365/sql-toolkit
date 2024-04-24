
/*
 * working table of single JSON records
 */
DROP TABLE IF EXISTS #JSONROWS DECLARE @ListGroupID INT = 1
SELECT
    SOURCEJSON = VALUE,
    PRIMKEY = NEWID()
INTO
    #JSONROWS
FROM
    DBO.LTBL_IMPORT_SHAREPOINTLIST_ONBOARDINGLISTITEMS_RAW WITH (NOLOCK)
    CROSS APPLY OPENJSON (JSON_DATA, '$.value')

/*
 * count of person IDs in the person-project table
 */
SELECT
    COUNT(DISTINCT ID)
FROM
    DBO.LTBL_IMPORT_SHAREPOINTLIST_ONBOARDINGLISTITEMS_SINGLEPROJECTLINE WITH (NOLOCK)

/*
 * expected number of single-project-line rows
 */
SELECT
    SUM(PERSONPROJECTCOUNT)
FROM
    (
        SELECT
            PERSONPROJECTCOUNT = (
                SELECT
                    COUNT(*)
                FROM
                    OPENJSON (JSON_QUERY(SOURCEJSON, '$.fields.Project'))
            )
        FROM
            #JSONROWS
    ) T

/*
 * quick random sample
 */
SELECT
    TOP 10 PERSONPROJECTCOUNT = (
        SELECT
            COUNT(*)
        FROM
            OPENJSON (JSON_QUERY(SOURCEJSON, '$.fields.Project'))
    )
FROM
    #JSONROWS
ORDER BY
    NEWID()

/*
 * number of rows in working table (should match: count of person IDs in the
 * person-project table )
 */
SELECT
    COUNT(*)
FROM
    #JSONROWS

/*
 * Rollup from the current solution (the count for list group 1 where the
 * persons have not been removed from the source should match the #jsonrows
 * count and count of person IDs in the person-project table)
 */
SELECT
    SHAREPOINTLISTGROUPID,
    ISREMOVEDFROMSOURCE,
    RECORDCOUNT = COUNT(*)
FROM
    DBO.LTBL_IMPORT_SHAREPOINTLIST_ONBOARDINGLISTITEMS WITH (NOLOCK)
GROUP BY
    ROLLUP (SHAREPOINTLISTGROUPID, ISREMOVEDFROMSOURCE)