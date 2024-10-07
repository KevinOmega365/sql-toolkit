DECLARE
    @GroupRef UNIQUEIDENTIFIER = (SELECT TOP 1 INTEGR_REC_GROUPREF from dbo.atbl_Import_Time_Documents_Final with (nolock)),
    @BatchRef UNIQUEIDENTIFIER = (SELECT TOP 1 INTEGR_REC_BATCHREF from dbo.atbl_Import_Time_Documents_Final with (nolock))

-- select
--     GroupRef = @GroupRef,
--     BatchRef = @BatchRef

EXEC dbo.lstp_Import_Time_Documents_SendToApproval
    @GroupRef = @GroupRef,
    @TaskRef = null,
    @BatchRef = @BatchRef
