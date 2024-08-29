


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
    join dbo.atbl_DCS_Documents D with (nolock)
        on D.Domain = R.Domain
        and D.DocumentID = R.DocumentID
    join dbo.atbl_DCS_DistributionSetup as DS with (nolock)
        on DS.Domain = IR.DCS_Domain
        and DS.DocumentID = IR.DCS_DocumentID
where
    DS.DistributionType = N'Approval'

-------------------------------------------------------------------------------
------------------------------------------------------------------ transform --
-------------------------------------------------------------------------------

----------------------------------------------------------- ApprovalDeadline --
update TrayItems
set
    DCS_ApprovalDeadline = [dbo].[afnc_DCS_GetDateDelayedByWorkdays] (
        TrayItems.DCS_Domain,
        GETUTCDATE(),
        ISNULL(Constants.DefaultApprovalDeadlineDays, 0),
        ISNULL(Contracts.WorkdaysCalendar, Constants.WorkdaysCalendar)
    )
from
    @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems TrayItems
    inner join dbo.atbl_DCS_Constants as Constants with (nolock)
        on Constants.Domain = TrayItems.DCS_Domain
    left join dbo.atbl_DCS_Contracts as Contracts with (nolock)
        on Contracts.Domain = TrayItems.DCS_Domain

-------------------------------------------------------------------------------
----------------------------------------------------------------- validation --
-------------------------------------------------------------------------------

-- todo: break down the where clause; add traceable checks

-------------------------------------------------------------------------------
-------------------------------------------------------------------- testing --
-------------------------------------------------------------------------------

select * from @ltbl_Import_DTS_DCS_RevisionsApprovalTrayItems
