
declare @domain nvarchar(128) = '145'

/*
 * Counts: how many revision-files DO NOT match
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

    MissingOnGuid =
    (
        select count(*)
        from
            dbo.atbl_DCS_RevisionsFiles P with (nolock)
            left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
                on P.Import_ExternalUniqueRef = I.DCS_Import_ExternalUniqueRef
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
            and I.PrimKey is null
    ),

    MissingOnOriginalFileName =
    (
        select count(*)
        from
            dbo.atbl_DCS_RevisionsFiles P with (nolock)
            left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
                on I.DCS_Domain = P.Domain
                and I.DCS_DocumentID = P.DocumentID
                and I.DCS_RevisionItemNo = P.RevisionItemNo
                and I.DCS_OriginalFileName = P.OriginalFileName
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
            and I.PrimKey is null
    ),

    MissingOnFileref =
    (
        select count(*)
        from
            dbo.atbl_DCS_RevisionsFiles P with (nolock)
            left join dbo.ltbl_Import_DTS_DCS_RevisionsFiles I with (nolock)
                on I.DCS_FileRef = P.FileRef
        where
            P.Domain = @domain
            and P.CreatedBy = 'af_Integrations_ServiceUser'
            and I.PrimKey is null
    )