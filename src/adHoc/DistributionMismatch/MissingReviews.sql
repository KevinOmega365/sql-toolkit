/*
 * Safety Critical
 * No DocWorkflowStatus
 * Domain = 128
 * Has CurrentRevision
 */
declare
    @Domain nvarchar(3) = N'128',
    @Criticality nvarchar(14) = N'SafetyCritical',
    @SourceDomain nvarchar(128) = N'%128%'


select
    count(*)
from
    [dbo].[aviw_DCS_WEB_DistributionMatrixCrossDomain]
where
    ([Domain] = @Domain)
    and (
        (
            [Criticality] in (@Criticality)
            and isnull("DocWorkflowStatus", N'') = ''
            and [SourceDomain] like @SourceDomain
            and isnull("CurrentRevision", N'') <> ''
        )
    )