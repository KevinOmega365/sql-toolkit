
-------------------------------------------------------------------------------

drop table if exists  #RevisionUpdatePreview
drop table if exists  #FilesToMerge
drop table if exists  #FixedPredatedRevisions
drop table if exists  #OffsetRevisionDates
drop table if exists  #RevisionsToFix

------------------------------------------------------------------ constants --

declare

    @ErrorMessage nvarchar(max) = 'Quality Failure: Cannot add non-current revision (lower revision number and not prior date)',

    @HighterRevisionWithPriorDatePattern nvarchar(max) = '%(prior date and not lower revision number)',
    @LowerRevisionWithLaterDatePattern nvarchar(max) = '%(lower revision number and not prior date)',

    @SetAfterCurrentAction nvarchar(max) = 'set revision date to one day after current',
    @SetBeforeCurrentAction nvarchar(max) = 'set revision date to one day prior to current',
    @NoChangesAction nvarchar(max) = 'insert with no changes',

    @ACTION_INSERT AS NVARCHAR(50) = (
        SELECT TOP 1 ID
        FROM dbo.atbl_Integrations_ImportStatuses WITH (NOLOCK)
        WHERE ID='ACTION_INSERT'
    ),

    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

-------------------------------------------------------------------------------
----------------------------------------------------------------- parameters --
-------------------------------------------------------------------------------

declare
    @GroupRef uniqueidentifier = @Valhall,
    @WhatIf bit = 1 -- !!! 1 to test | 0 to make changes !!!

-------------------------------------------------------------------------------
------------------------------------------------------------------ variables --
-------------------------------------------------------------------------------

-------------------------------------------------------------- get batch ref --
declare
    @BatchRef uniqueidentifier = (
        select top 1
            INTEGR_REC_BATCHREF
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @GroupRef
    )

---------------------------------------------------------- get revision keys --
select
    PrimKey
into
    #RevisionsToFix
from
    dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
where
    INTEGR_REC_GROUPREF = @GroupRef
    and INTEGR_REC_ERROR = @ErrorMessage

-------------------------------------------------------------------------------
----------------------------------------------- Calculate new revision dates --
-------------------------------------------------------------------------------

select
    Domain,
    DocumentID,
    Revision,
    RevisionDate,
    IsInPims,
    RevisionOrder = row_number() over (
        partition by
            Domain,
            DocumentID
        order by
            Revision
    ),
    PrimKey
into
    #OffsetRevisionDates
from
    (
        select -- Pims Revsions
            R.Domain,
            R.DocumentID,
            R.Revision,
            R.RevisionDate,
            IsInPims = cast(1 as bit),
            R.PrimKey
        from
            dbo.atbl_DCS_Revisions R with (nolock)
        where
            exists (
                select *
                from
                    #RevisionsToFix RTF
                    join dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
                        on IR.PrimKey = RTF.PrimKey
                where
                    IR.DCS_Domain = R.Domain
                    and IR.DCS_DocumentID = R.DocumentID
            )
            
        union

        select -- Import (only) revisons
            I.DCS_Domain,
            I.DCS_DocumentID,
            I.DCS_Revision,
            I.DCS_RevisionDate,
            IsInPims = cast(0 as bit),
            I.PrimKey
        from
            dbo.ltbl_Import_DTS_DCS_Revisions I with (nolock)
            left join dbo.atbl_DCS_Revisions R with (nolock)
                on R.Domain = I.DCS_Domain
                and R.DocumentID = I.DCS_DocumentID
                and R.Revision = I.DCS_Revision
        where
            exists (
                select *
                from #RevisionsToFix E
                where
                    E.PrimKey = I.PrimKey
            )
            and R.PrimKey is null
    ) T

-------------------------------------------------------------------------------

select
    A.Domain,
    A.DocumentID,
    A.Revision,
    NewDate = case
        when A.IsInPims = 0
        then dateadd(day, A.RevisionOrder - NextPimsRevOrder.RevisionOrder, NextPimsRev.RevisionDate)
        else null
    end,
    A.RevisionDate,
    A.IsInPims,
    A.PrimKey
into
    #FixedPredatedRevisions
from
    #OffsetRevisionDates A
    cross apply (
        select RevisionOrder = min(RevisionOrder)
        from #OffsetRevisionDates NPRO
        where
            NPRO.Domain = A.Domain
            and NPRO.DocumentID = A.DocumentID
            and NPRO.RevisionOrder > A.RevisionOrder
            and NPRO.IsInPims = 1
    ) NextPimsRevOrder
    left join #OffsetRevisionDates NextPimsRev
        on NextPimsRev.Domain = A.Domain
        and NextPimsRev.DocumentID = A.DocumentID
        and NextPimsRev.RevisionOrder = NextPimsRevOrder.RevisionOrder
where
    A.IsInPims = 0
order by
    A.Domain,
    A.DocumentID,
    A.RevisionOrder

-------------------------------------------------------------------------------
----------------------------------------------------------- Update and merge --
-------------------------------------------------------------------------------

---------------------------------------------------- revision update preview --

select

    Domain = IR.DCS_Domain,
    -- activate_link_document =
    --     '<a href="' +
    --     '/dcs-documents-details?Domain=' +
    --     IR.DCS_Domain +
    --     '&DocID=' +
    --     IR.DCS_DocumentID +
    --     '">' +
    --     IR.DCS_DocumentID +
    --     '</a>',
    DocumentID = IR.DCS_DocumentID,
    URL = '=HYPERLINK("https://pims.akerbp.com/dcs-documents-details?Domain="&A2&"&DocID="&B2, "Open")',
    Revision = IR.DCS_Revision,
    RevisionDate = IR.DCS_RevisionDate,
    ORD.NewDate,
    RecordStatus = IR.INTEGR_REC_STATUS,
    NewStatus = @ACTION_INSERT,
    ErrorMessage = IR.INTEGR_REC_ERROR,
    NoError = ''
into
    #RevisionUpdatePreview
from
    dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
    join #FixedPredatedRevisions ORD with (nolock)
        on ORD.PrimKey = IR.PrimKey

--------------------------------------------------------- modify import data --

if ( @WhatIf = 0 )
begin
    update IR
    set
        IR.DCS_RevisionDate = ORD.NewDate,
        IR.INTEGR_REC_STATUS = @ACTION_INSERT,
        IR.INTEGR_REC_ERROR = ''
    from
        dbo.ltbl_Import_DTS_DCS_Revisions IR with (nolock)
        join #FixedPredatedRevisions ORD with (nolock)
            on ORD.PrimKey = IR.PrimKey
end

-------------------------------------------------------- run merge revisions --

if ( @WhatIf = 0 )
begin

    if ( @GroupRef = @Valhall )
        begin
            execute [dbo].[lstp_Import_DTS_DCS_MergeRevisions_Valhall]
                @GroupRef = @GroupRef,
                @TaskRef = null,
                @BatchRef = @BatchRef
        end

    else if ( @GroupRef = @Yggdrasil )
        begin
            execute [dbo].[lstp_Import_DTS_DCS_MergeRevisions_Yggdrasil]
                @GroupRef = @GroupRef,
                @TaskRef = null,
                @BatchRef = @BatchRef
        end

    else if ( @GroupRef = @Munin )
        begin
            execute [dbo].[lstp_Import_DTS_DCS_MergeRevisions_Munin]
                @GroupRef = @GroupRef,
                @TaskRef = null,
                @BatchRef = @BatchRef
        end

    else
        begin
            execute [dbo].[lstp_Import_DTS_DCS_MergeRevisions]
            @GroupRef = @GroupRef,
            @TaskRef = null,
            @BatchRef = @BatchRef
        end

end

---------------------------------------------------- files to merge (report) --

select
    INTEGR_REC_STATUS,
    DCS_Domain,
    DCS_DocumentID,
    DCS_Revision,
    DCS_OriginalFileName
into
    #FilesToMerge
from
    dbo.ltbl_Import_DTS_DCS_RevisionsFiles as IRF with (nolock)
    join #FixedPredatedRevisions as FPR
        on IRF.DCS_Domain = FPR.Domain
        and IRF.DCS_DocumentID = FPR.DocumentID
        and IRF.DCS_Revision = FPR.Revision

---------------------------------------------------- update file import data --

if ( @WhatIf = 0 )
begin
    update IRF
    set
        INTEGR_REC_STATUS = @ACTION_INSERT
    from
        dbo.ltbl_Import_DTS_DCS_RevisionsFiles as IRF
        join #FixedPredatedRevisions as FPR
            on IRF.DCS_Domain = FPR.Domain
            and IRF.DCS_DocumentID = FPR.DocumentID
            and IRF.DCS_Revision = FPR.Revision
end

---------------------------------------------------------------- merge files --

if ( @WhatIf = 0 )
begin
    execute [dbo].[lstp_Import_DTS_DCS_MergeRevisionsFiles]
        @GroupRef = @GroupRef,
        @TaskRef = null,
        @BatchRef = @BatchRef
end

------------------------------------------------------------------ reporting --

select * from #RevisionUpdatePreview

select * from #FilesToMerge

select * from #FixedPredatedRevisions

select * from #OffsetRevisionDates

select * from #RevisionsToFix

-------------------------------------------------------------------------------