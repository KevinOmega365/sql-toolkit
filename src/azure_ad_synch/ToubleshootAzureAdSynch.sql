
/**
 * Toubleshoot Azure AD Synch
 *  - Check the jobs and the queue
 *  - Clear the jobs and the queue
 *  - Restart the Synchronization
 */

/*
    DELETE dbo.atbl_AzureAdSync_Queue
    DELETE dbo.atbl_AzureAdSync_Jobs
*/

/*
    EXEC dbo.astp_AzureAdSync_StartSynch
*/

SELECT
    PrimKey,
    ID,
    Created,
    CreatedBy,
    GroupPrimKey,
    URL,
    Token,
    RunID,
    JobID
FROM
    dbo.atbl_AzureAdSync_Queue AS [Q] WITH (NOLOCK)


SELECT
    PrimKey,
    Created,
    CreatedBy,
    Updated,
    UpdatedBy,
    CUT,
    CDL,
    Type,
    Parent,
    State,
    GroupPrimKey
FROM
    dbo.atbl_AzureAdSync_Jobs AS [J] WITH (NOLOCK)