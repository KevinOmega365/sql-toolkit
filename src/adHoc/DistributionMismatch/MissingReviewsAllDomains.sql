
/*

    Domain List
        145
        128
        148
        175
        181
        187
        153

    Criticality
        SafetyCritical

    CurrentRevision
        NOT empty

    DocWorkflowStatus
        IS empty

    ReviewResponsible
        NOT empty

    NOT Superseded

    NOT Voided

*/

declare
    @DomainPattern nvarchar(128) = '145',
    @CriticalityPattern nvarchar(14) = '%',
    @HideReviewResponsible bit = 0


    select --Count = count(*)
        D.Domain,
        D.DocumentID,
        URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2; "Open "&B2)',
        D.CurrentRevision,
        D.CurrentStep,
        D.Criticality,
        D.DocWorkflowStatus,
        ReviewResponsible = case 
            when @HideReviewResponsible = 0
            then CR.ReviewResponsible
            else sys.fn_varbintohexstr(HASHBYTES ('SHA2_256', CR.ReceiverPerson))
        end
    from
        dbo.atbl_DCS_Documents D with (nolock)
        ---------------------------------------------------------------------------
        ---------------------- start: aviw_DCS_WEB_DistributionMatrixCrossDomain --
        ---------------------------------------------------------------------------
        inner join dbo.atbl_DCS_Settings as STS with (nolock)
            on STS.Domain = D.Domain
        outer apply (
            select
                null as Step,
                null as PrimKey --for distribution without step
            union all
            select
                DTS.Step,
                DTS.PrimKey
            from
                dbo.atbl_DCS_DocumentTypesSteps DTS with (nolock)
                inner join dbo.atbl_DCS_Steps S with (nolock)
                    on S.Domain = DTS.Domain
                    and S.Step = DTS.Step
                    and S.IsObsolete = 0
            where
                DTS.Domain = D.SourceDomain
                and DTS.PlantID = D.PlantID
                and DTS.DocumentType = D.DocumentType
                and DTS.RequireDistinctDistributionSetup = 1
        ) as SDS
        outer apply (
            select
                null as PrimKey,
                null as ProjectPlantID,
                null as ProjectID,
                null as ContractNo,
                null as Description,
                null as ProjectPlantNo,
                null as ProjectPlantDescription,
                null as CompanyID,
                null as ContractDescription,
                null as ProjectContractNo
            where
                D.ContractNo is null
            union all
            select
                null as PrimKey,
                null as ProjectPlantID,
                null as ProjectID,
                null as ContractNo,
                null as Description,
                null as ProjectPlantNo,
                null as ProjectPlantDescription,
                C.CompanyID,
                C.Description as ContractDescription,
                null as ProjectContractNo
            from
                dbo.atbl_DCS_Contracts as C with (nolock)
            where
                C.Domain = D.SourceDomain
                and C.ContractNo = D.ContractNo
            union all
            select
                DP.PrimKey,
                DP.PlantID as ProjectPlantID,
                DP.ProjectID,
                DP.ContractNo,
                Proj.Description,
                P.PlantNo as ProjectPlantNo,
                isnull(' - ' + P.Description, '') as ProjectPlantDescription,
                C.CompanyID,
                C.Description as ContractDescription,
                DP.ContractNo as ProjectContractNo
            from
                dbo.atbl_DCS_DocumentsProjects as DP with (nolock)
                inner join dbo.atbl_DCS_Contracts as C with (nolock)
                    on C.Domain = DP.Domain
                    and C.ContractNo = DP.ContractNo
                inner join dbo.atbl_Asset_Projects as Proj with (nolock)
                    on Proj.PlantID = DP.PlantID
                    and Proj.ProjectID = DP.ProjectID
                inner join dbo.atbl_Asset_Plants as P with (nolock)
                    on P.PlantID = Proj.PlantID
            where
                STS.EnableConcurrentEngineering = 1
                and DP.Domain = D.SourceDomain
                and DP.DocumentID = D.DocumentID
                and DP.CancelledDate is null
                and Proj.CancelledDate is null
                and exists (
                    select
                        1
                    where
                        Proj.ClosedDate is null
                    union all
                    select
                        1
                    where
                        Proj.ClosedDate > getutcdate()
                )
            union all
            select distinct
                D.PrimKey,
                DP.PlantID as ProjectPlantID,
                DP.ProjectID,
                'Project Default' as ContractNo,
                Proj.Description,
                P.PlantNo as ProjectPlantNo,
                isnull(' - ' + P.Description, '') as ProjectPlantDescription,
                null as CompanyID,
                null as ContractDescription,
                null as ProjectContractNo
            from
                dbo.atbl_DCS_DocumentsProjects as DP with (nolock)
                inner join dbo.atbl_Asset_Projects as Proj with (nolock)
                    on Proj.PlantID = DP.PlantID
                    and Proj.ProjectID = DP.ProjectID
                inner join dbo.atbl_Asset_Plants as P with (nolock)
                    on P.PlantID = Proj.PlantID
            where
                STS.EnableConcurrentEngineering = 1
                and DP.Domain = D.SourceDomain
                and DP.DocumentID = D.DocumentID
                and DP.CancelledDate is null
                and Proj.CancelledDate is null
                and exists (
                    select
                        1
                    where
                        Proj.ClosedDate is null
                    union all
                    select
                        1
                    where
                        Proj.ClosedDate > getutcdate()
                )
        ) as PRJS
        outer apply (
            select
                cast(
                    concat(isnull(PRJS.PrimKey, D.PrimKey), SDS.PrimKey) as nvarchar(MAX)
                ) as PrimKey,
                PRJS.ProjectPlantID,
                PRJS.ProjectID,
                PRJS.ContractNo,
                PRJS.Description,
                PRJS.ProjectPlantNo,
                PRJS.ProjectPlantDescription,
                PRJS.CompanyID,
                PRJS.ContractDescription,
                PRJS.ProjectContractNo,
                SDS.Step as Step
        ) as DS_Setup
        outer apply (
            select
                P.PersonID as ReceiverPerson,
                P.LastName + N' ' + P.FirstName as ReviewResponsible,
                P.CompanyID,
                cast(isnull(E.IsExpired, 0) as bit) as CommentsResponsibleIsExpired
            from
                dbo.atbl_ProjectSetup_Persons as P with (nolock)
                outer apply (
                    select
                        1 as IsExpired
                    where
                        P.Expired = 1
                    union
                    select
                        1 as IsExpired
                    from
                        dbo.atbl_ProjectSetup_TeamMembers as TM with (nolock)
                    where
                        TM.Domain = D.Domain
                        and TM.PersonID = P.PersonID
                        and TM.Expired = 1
                    union
                    select
                        1 as IsExpired
                    from
                        dbo.stbl_System_Users as U with (nolock)
                    where
                        U.Login = P.Login
                        and U.UserExpired = 1
                ) as E
            where
                exists (
                    select
                        *
                    from
                        dbo.atbl_DCS_DistributionSetup as DS with (nolock)
                        inner join dbo.atbl_DCS_ActionTypes as AT with (nolock)
                            on AT.ActionType = DS.ActionType
                            and AT.SystemActionType = 'Review Responsible'
                    where
                        DS.Domain = D.Domain
                        and DS.DocumentID = D.DocumentID
                        and P.PersonID = DS.ReceiverPerson
                        and DS.DistributionType = 'Review'
                        and exists (
                            select
                                DS_Setup.ProjectID,
                                DS_Setup.ProjectPlantID,
                                DS_Setup.ProjectContractNo,
                                DS_Setup.Step
                            intersect
                            select
                                DS.ProjectID,
                                DS.ProjectPlantID,
                                DS.ProjectContractNo,
                                DS.Step
                        )
                )
        ) as CR
        ---------------------------------------------------------------------------
        ------------------------ end: aviw_DCS_WEB_DistributionMatrixCrossDomain --
        ---------------------------------------------------------------------------
    where
        D.Domain like @DomainPattern
        and D.Criticality like @CriticalityPattern
        and D.Domain in (
            '145',
            '128',
            '148',
            '175',
            '181',
            '187',
            '153'
        )
        and isnull(D.CurrentRevision, '') <> ''
        and isnull(D.DocWorkflowStatus, '') = ''
        and isnull(CR.ReviewResponsible, '') <> ''
        and D.IsSuperseded = 0
        and D.IsVoided = 0
