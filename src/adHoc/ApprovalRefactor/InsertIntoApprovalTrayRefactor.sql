


/*
 * testing table
 * this should probably be reified
 * it would have the full spread of ltbl_Imporrt columns
 */
declare @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems table
(
    INTEGR_REC_STATUS NVARCHAR(50),
    INTEGR_REC_ERROR NVARCHAR(MAX),
    INTEGR_REC_TRACE NVARCHAR(MAX),
    DCS_Domain NVARCHAR(128),
    DCS_DocumentID NVARCHAR(50),
    DCS_RevisionItemNo INT,
    DCS_Receiver NVARCHAR(10),
    DCS_ActionType NVARCHAR(16),
    DCS_SequentialOrder INT,
    DCS_ApprovalDeadline DATE,
    DCS_SystemGenerated BIT,
    DCS_Selected BIT
)

-------------------------------------------------------------------------------
------------------------------------------------------------------ constants --
-------------------------------------------------------------------------------

DECLARE @IMPORTED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='IMPORTED_OK') -- Transition
DECLARE @TRANSFORMED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='TRANSFORMED_OK') -- Transition
DECLARE @VALIDATED_OK AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='VALIDATED_OK') -- Transition
DECLARE @VALIDATION_FAILED AS NVARCHAR(50) = (SELECT TOP 1 ID FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK) WHERE ID='VALIDATION_FAILED') -- Final

DECLARE @TraceBaseJson nvarchar(max) = '{ "action": [], "scope": [], "validation": [], "warning": [] }';
DECLARE @TraceItem nvarchar(256);

-------------------------------------------------------------------------------
---------------------------------------------------------------------- stage --
-------------------------------------------------------------------------------

/*
 * How do we pick off the right revisions?
 */

insert into @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems
(
    INTEGR_REC_STATUS,
    INTEGR_REC_ERROR,
    INTEGR_REC_TRACE,
    DCS_Domain,
    DCS_DocumentID,
    DCS_RevisionItemNo,
    DCS_Receiver,
    DCS_ActionType,
    DCS_SequentialOrder,
    DCS_ApprovalDeadline,
    DCS_SystemGenerated,
    DCS_Selected
)
select
    INTEGR_REC_STATUS = 'IMPORTED_OK',
    INTEGR_REC_ERROR = null,
    INTEGR_REC_TRACE = null,
    R.Domain,
    R.DocumentID,
    R.RevisionItemNo,
    DS.ReceiverPerson,
    DS.ActionType,
    DS.SequentialOrder,
    ApprovalDeadline = null, -- see transform
    SystemGenerated = 1,
    Selected = 0
from
    dbo.ltbl_Import_DTS_DCS_Revisions as IR with (nolock)
    join dbo.atbl_DCS_Revisions as R with (nolock)
        on R.Domain = IR.DCS_Domain
        and R.DocumentID = IR.DCS_DocumentID
        and R.Revision = IR.DCS_Revision
    join dbo.atbl_DCS_DistributionSetup as DS with (nolock)
        on DS.Domain = IR.DCS_Domain
        and DS.DocumentID = IR.DCS_DocumentID
where
    DS.DistributionType = N'Approval'

-------------------------------------------------------------------------------
------------------------------------------------------------------ transform --
-------------------------------------------------------------------------------

----------------------------------------------------------- ApprovalDeadline --
update T
set
    DCS_ApprovalDeadline = [dbo].[afnc_DCS_GetDateDelayedByWorkdays] (
        T.DCS_Domain,
        GETUTCDATE(),
        ISNULL(Constants.DefaultApprovalDeadlineDays, 0),
        ISNULL(Contracts.WorkdaysCalendar, Constants.WorkdaysCalendar)
    )
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems T
    inner join dbo.atbl_DCS_Constants as Constants with (nolock)
        on Constants.Domain = T.DCS_Domain
    left join dbo.atbl_DCS_Contracts as Contracts with (nolock)
        on Contracts.Domain = T.DCS_Domain

-------------------------------------------------------------------------------
----------------------------------------------------------------- validation --
-------------------------------------------------------------------------------

-------------------------------------------------------------------- IsDraft --
set @TraceItem = 'Revision is not set to draft'
UPDATE T
SET
    INTEGR_REC_TRACE = JSON_MODIFY(
        ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
        'append $.validation',
        @TraceItem
    ),
    INTEGR_REC_STATUS = @VALIDATION_FAILED
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems as T -- with (nolock)
    join dbo.atbl_DCS_Revisions as R with (nolock)
        on R.Domain = T.DCS_Domain
        and R.DocumentID = T.DCS_DocumentID
        and R.RevisionItemNo = T.DCS_RevisionItemNo
where
    R.IsDraft <> 1
    -- and I.INTEGR_REC_BATCHREF = @BatchRef


----------------------------------------------------- Automatic distribution --
set @TraceItem = 'Automatic distribution is not configured'
UPDATE T
SET
    INTEGR_REC_TRACE = JSON_MODIFY(
        ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
        'append $.validation',
        @TraceItem
    ),
    INTEGR_REC_STATUS = @VALIDATION_FAILED
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems as T -- with (nolock)
    join dbo.atbl_DCS_Revisions as R with (nolock)
        on R.Domain = T.DCS_Domain
        and R.DocumentID = T.DCS_DocumentID
        and R.RevisionItemNo = T.DCS_RevisionItemNo
    join dbo.atbl_DCS_Documents as D with (nolock)
        on R.Domain = R.Domain
        and R.DocumentID = R.DocumentID
    inner join dbo.atbl_DCS_Settings as S with (nolock)
      on S.Domain = D.Domain
    left join dbo.atbl_DCS_Contracts as C with (nolock)
      on C.Domain = D.Domain
      and C.ContractNo = ISNULL(R.ProjectContractNo, D.ContractNo)
where
    (
        S.AutoPopulateApprovalTrayOnNewRev = 0 -- non-null: OK
        and C.AutomaticallyDistributeSubmittals = 0 -- non-null: OK
    )
    -- and I.INTEGR_REC_BATCHREF = @BatchRef


------------------------------------------------------------ RequireApproval --
set @TraceItem = 'Approval is not required'
UPDATE T
SET
    INTEGR_REC_TRACE = JSON_MODIFY(
        ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
        'append $.validation',
        @TraceItem
    ),
    INTEGR_REC_STATUS = @VALIDATION_FAILED
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems as T -- with (nolock)
    join dbo.atbl_DCS_Revisions as R with (nolock)
        on R.Domain = T.DCS_Domain
        and R.DocumentID = T.DCS_DocumentID
        and R.RevisionItemNo = T.DCS_RevisionItemNo
    join dbo.atbl_DCS_Documents as D with (nolock)
        on R.Domain = R.Domain
        and R.DocumentID = R.DocumentID
    INNER JOIN dbo.atbl_DCS_DocumentTypesSteps AS DTS WITH (NOLOCK)
      ON DTS.Domain = D.Domain
      AND DTS.PlantID = D.PlantID
      AND DTS.DocumentType = D.DocumentType
      AND DTS.Step = R.Step
where
    DTS.RequireApproval <> 1 -- todo: handle nulls if they can exist
    -- and I.INTEGR_REC_BATCHREF = @BatchRef


------------------------------------------------------ EnableApprovalProcess --
set @TraceItem = 'Approval is not process enabled'
UPDATE T
SET
    INTEGR_REC_TRACE = JSON_MODIFY(
        ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
        'append $.validation',
        @TraceItem
    ),
    INTEGR_REC_STATUS = @VALIDATION_FAILED
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems as T -- with (nolock)
    INNER JOIN dbo.atbl_DCS_Settings AS S WITH (NOLOCK)
      ON S.Domain = T.DCS_Domain
where
    S.EnableApprovalProcess <> 1 -- todo: handle nulls if they can exist
    -- and I.INTEGR_REC_BATCHREF = @BatchRef

-------------------------------------------------------------------------------
------------------------------------------------------ EnableApprovalProcess --
set @TraceItem = 'Approval is not process enabled'
UPDATE T
SET
    INTEGR_REC_TRACE = JSON_MODIFY(
        ISNULL(NULLIF(T.INTEGR_REC_TRACE, ''), @TraceBaseJson),
        'append $.validation',
        @TraceItem
    ),
    INTEGR_REC_STATUS = @VALIDATION_FAILED
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems as T -- with (nolock)

    join dbo.atbl_DCS_Documents as D with (nolock)
        on R.Domain = R.Domain
        and R.DocumentID = R.DocumentID
    join dbo.atbl_DCS_Revisions as R with (nolock)
        on R.Domain = T.DCS_Domain
        and R.DocumentID = T.DCS_DocumentID
        and R.RevisionItemNo = T.DCS_RevisionItemNo
     JOIN dbo.atbl_DCS_DistributionSetup AS DS WITH (NOLOCK)
      ON DS.Domain = T.DCS_Domain
      AND DS.DocumentID = T.DCS_DocumentID
      AND DS.DistributionType = N'Approval'
     JOIN dbo.atbl_DCS_DocumentTypesSteps AS DTS WITH (NOLOCK)
      ON DTS.Domain = D.Domain
      AND DTS.PlantID = D.PlantID
      AND DTS.DocumentType = D.DocumentType
      AND DTS.Step = R.Step
where
    isnull(DTS.RequireDistinctDistributionSetup, 0) <> 1

/* todo:

    test intersect code

    find out about these:

        * R.ProjectPlantID,
        * R.ProjectID,
        * R.ProjectContractNo

    Are they denormalized?
    Do we need to start setting them?
*/
    -- and I.INTEGR_REC_BATCHREF = @BatchRef


-------------------------------------------------------------------------------
-------------------------------------------------------------------- testing --
-------------------------------------------------------------------------------

select * from @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems
