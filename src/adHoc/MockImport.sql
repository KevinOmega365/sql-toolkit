declare
    @GroupRef uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @BatchRef uniqueidentifier = 'd4037b5c-3f2a-4416-9261-fb1c7a9652b3'

delete dbo.ltbl_Import_DTS_DCS_Documents where INTEGR_REC_GROUPREF = @GroupRef
delete dbo.ltbl_Import_DTS_DCS_Revisions where INTEGR_REC_GROUPREF = @GroupRef    
delete dbo.ltbl_Import_DTS_DCS_RevisionsFiles where INTEGR_REC_GROUPREF = @GroupRef

execute [lstp_Import_DTS_DCS_Transform]
    @GroupRef = @GroupRef,
    @TaskRef = null,
    @BatchRef = @BatchRef
