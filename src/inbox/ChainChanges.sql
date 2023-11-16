declare @ProArcChainsUpdate table (
	GroupRef UNIQUEIDENTIFIER,
	Domain NVARCHAR(128),
	Chain NVARCHAR(24),
	ReasonForIssue NVARCHAR(24),
	Description NVARCHAR(256),
	DefaultStep NVARCHAR(10),
	PriorityTwoStep NVARCHAR(10),
	PriorityOneStep NVARCHAR(10),
	CumulativeProgress INT,
	StepProgress INT
)
insert into @ProArcChainsUpdate
(
    GroupRef,
    Domain,
    Chain,
    ReasonForIssue,
    Description,
    DefaultStep,
    PriorityTwoStep,
    PriorityOneStep,
    CumulativeProgress,
    StepProgress
)
values
    ADD_UPDATED_VALUE_FROM_XLSX_PARSER_OUTPUT

-------------------------------------------------------------------------------

/**
 * Count of new or removed chains
 */
-- select ChangeCount = count(*)
-- from
--     @ProArcChainsUpdate New
--     full outer join dbo.ltbl_Import_Mapping_ProArcChains Existing with (nolock)
--         on Existing.Domain = New.Domain
--         and Existing.Chain = New.Chain
--         and Existing.ReasonForIssue = New.ReasonForIssue
-- where
--     Existing.Domain is null
--     or New.Domain is null

/**
 * Changes
 */
select
	DomainChanged = case when isnull(Existing.Domain, '') <> isnull(New.Domain, '') then 'x' else '' end,
	ExistingDomain = Existing.Domain,
	NewDomain = New.Domain,
	ChainChanged = case when isnull(Existing.Chain, '') <> isnull(New.Chain, '') then 'x' else '' end,
	ExistingChain = Existing.Chain,
	NewChain = New.Chain,
	ReasonForIssueChanged = case when isnull(Existing.ReasonForIssue, '') <> isnull(New.ReasonForIssue, '') then 'x' else '' end,
	ExistingReasonForIssue = Existing.ReasonForIssue,
	NewReasonForIssue = New.ReasonForIssue,
	DescriptionChanged = case when isnull(Existing.Description, '') <> isnull(New.Description, '') then 'x' else '' end,
	ExistingDescription = Existing.Description,
	NewDescription = New.Description,
	DefaultStepChanged = case when isnull(Existing.DefaultStep, '') <> isnull(New.DefaultStep, '') then 'x' else '' end,
	ExistingDefaultStep = Existing.DefaultStep,
	NewDefaultStep = New.DefaultStep,
	PriorityTwoStepChanged = case when isnull(Existing.PriorityTwoStep, '') <> isnull(New.PriorityTwoStep, '') then 'x' else '' end,
	ExistingPriorityTwoStep = Existing.PriorityTwoStep,
	NewPriorityTwoStep = New.PriorityTwoStep,
	PriorityOneStepChanged = case when isnull(Existing.PriorityOneStep, '') <> isnull(New.PriorityOneStep, '') then 'x' else '' end,
	ExistingPriorityOneStep = Existing.PriorityOneStep,
	NewPriorityOneStep = New.PriorityOneStep,
	CumulativeProgressChanged = case when isnull(Existing.CumulativeProgress, '') <> isnull(New.CumulativeProgress, '') then 'x' else '' end,
	ExistingCumulativeProgress = Existing.CumulativeProgress,
	NewCumulativeProgress = New.CumulativeProgress,
	StepProgressChanged = case when isnull(Existing.StepProgress, '') <> isnull(New.StepProgress, '') then 'x' else '' end,
	ExistingStepProgress = Existing.StepProgress,
	NewStepProgress = New.StepProgress
from
    @ProArcChainsUpdate New
    full outer join dbo.ltbl_Import_Mapping_ProArcChains Existing with (nolock)
        on Existing.Domain = New.Domain
        and Existing.Chain = New.Chain
        and Existing.ReasonForIssue = New.ReasonForIssue
where
    isnull(New.Domain, '') <> isnull(Existing.Domain, '')
    or isnull(New.Chain, '') <> isnull(Existing.Chain, '')
    or isnull(New.ReasonForIssue, '') <> isnull(Existing.ReasonForIssue, '')
    or isnull(New.Description, '') <> isnull(Existing.Description, '')
    or isnull(New.DefaultStep, '') <> isnull(Existing.DefaultStep, '')
    or isnull(New.PriorityTwoStep, '') <> isnull(Existing.PriorityTwoStep, '')
    or isnull(New.PriorityOneStep, '') <> isnull(Existing.PriorityOneStep, '')
    or isnull(New.CumulativeProgress, '') <> isnull(Existing.CumulativeProgress, '')
    or isnull(New.StepProgress, '') <> isnull(Existing.StepProgress, '')


