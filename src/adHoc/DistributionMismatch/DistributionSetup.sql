


-------------------------------------------------------------------------------
---------------------------------------------- data from distribution matrix --
-------------------------------------------------------------------------------

/*
 * Document dist matrix
 */
declare @Param0 nvarchar(128)=N'145'
declare @Param1 nvarchar(50)=N'%PWP-AK-N-81802-005%'

SELECT
    [PrimKey],
    [DocumentCreated],
    [SourceDomain],
    [Domain],
    [Title],
    [DocumentID],
    [Step],
    [WorkPackID],
    [ContractNo],
    [ReviewClass],
    [ClientReviewClass],
    [CurrentRevision],
    [SuggestedReviewClass],
    [SRCDate],
    [ReviewStatus],
    [ReceivedDate],
    [ContractorDocumentID],
    [ReviewResponsible],
    [ReviewResponsibleWithCompany],
    [DocsCustomText1],
    [DocsCustomText2],
    [DocsCustomText3],
    [DocsCustomText4],
    [AssetCustomText1],
    [ReviewConsolidatorWithCompany],
    [CurrentStep],
    [DocWorkflowStatus],
    [InstanceCustomText1],
    [InstanceCustomText2],
    [InstanceCustomText3],
    [InstanceCustomText4],
    [ReceiverList]
FROM
    [dbo].[aviw_DCS_WEB_DistributionMatrixCrossDomain]
WHERE
    (
        [Domain] = @Param0
        AND [DocumentID] LIKE @Param1
    )
ORDER BY PrimKey ASC
OFFSET 0 ROWS
FETCH FIRST 25 ROWS ONLY

/*
 * Distribution setup...
 */
declare @Param0 nvarchar(128)=N'145'
declare @Param1 nvarchar(50)=N'PWP-AK-N-81802-005'
declare @Param2 nvarchar(max)=N'F4348B3E-2AE5-4902-952E-774A294C1E1F'
declare @Param3 nvarchar(6)=N'Review'
declare @Param4 nvarchar(8)=N'Internal'
declare @Param5 nvarchar(8)=N'Approval'
declare @Param6 nvarchar(8)=N'Redlines'

SELECT TOP 50
    [Domain],
    [DocumentID],
    [DistributionType],
    [ReceiverPerson],
    [Format],
    [ProjectPlantID],
    [Step],
    [ProjectID],
    [ProjectContractNo],
    [ActionType],
    [SequentialOrder],
    [DeadlineDelayDays],
    [ActionTypeDescription],
    [FormatDescription],
    [PersonFullName],
    [PersonFullNameWithCompanyID],
    [IsExpired],
    [IsExternal],
    [FilterPrimKey],
    [PrimKey]
FROM
    [dbo].[aviw_DCS_DistributionMatrixDocumentsReceiversCrossDomain]
WHERE
    (
        [Domain] = @Param0
        AND [DocumentID] = @Param1
        AND [FilterPrimKey] = @Param2
        AND [DistributionType] IN (
            @Param3,
            @Param4,
            @Param5,
            @Param6
        )
    )

