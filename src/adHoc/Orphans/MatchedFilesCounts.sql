
declare @domain nvarchar(128) = '145'

/*
 * Counts: how many revision-files match
 */
select
    CreatedByIntegration =
    (
        select count(*)
        from dbo.atbl_DCS_RevisionsFiles with (nolock)
        where
            Domain = @domain
            and CreatedBy = 'af_Integrations_ServiceUser'
    ),

    ImportStaging =
    (
        select count(*)
        from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
        where
            DCS_Domain = @domain
            and CreatedBy = 'af_Integrations_ServiceUser'
    ),

    JoinedOnGuid =
    (
        select count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
            join dbo.atbl_DCS_RevisionsFiles P with (nolock)
                on I.DCS_Import_ExternalUniqueRef = P.Import_ExternalUniqueRef
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
    ),

    JoinedOnOriginalFileName =
    (
        select count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
            join dbo.atbl_DCS_RevisionsFiles P with (nolock)
                on P.Domain = I.DCS_Domain
                and P.DocumentID = I.DCS_DocumentID
                and P.RevisionItemNo = I.DCS_RevisionItemNo
                and P.OriginalFileName = I.DCS_OriginalFileName
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
    ),

    JoinedOnFileref =
    (
        select count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
            join dbo.atbl_DCS_RevisionsFiles P with (nolock)
                on P.FileRef = I.DCS_FileRef
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
    )