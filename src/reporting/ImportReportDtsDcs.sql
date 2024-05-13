declare @groupRef uniqueidentifier = '4752565e-84f0-4592-a446-f0720bbc3540'

-------------------------------------------------------------------------------
-------------------------------------------------------------  Import Totals --
-------------------------------------------------------------------------------
select
    EntitiyCounts.Entity,
    EntitiyCounts.Count
from
    (
        select
            Entity = 'Documents',
            EntitySortOrder = 1,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef

    union all

        select
            Entity = 'Revisions',
            EntitySortOrder = 2,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef

    union all

        select
            Entity = 'RevisionFiles',
            EntitySortOrder = 3,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionFiles with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef

    ) EntitiyCounts
order by
    EntitySortOrder

-------------------------------------------------------------------------------
-------------------------------------------------------------- Status Totals --
-------------------------------------------------------------------------------
select
    StatusCounts.Entity,
    StatusCounts.ImportStatus,
    StatusCounts.Count
from
    (
        select
            ImportStatus = INTEGR_REC_STATUS,
            Entity = 'Documents',
            EntitySortOrder = 1,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
        group by
            INTEGR_REC_STATUS

    union all

        select
            ImportStatus = INTEGR_REC_STATUS,
            Entity = 'Revisions',
            EntitySortOrder = 2,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
        group by
            INTEGR_REC_STATUS

    union all

        select
            ImportStatus = INTEGR_REC_STATUS,
            Entity = 'RevisionFiles',
            EntitySortOrder = 3,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionFiles with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
        group by
            INTEGR_REC_STATUS

    ) StatusCounts
order by
    EntitySortOrder,
    ImportStatus

-------------------------------------------------------------------------------
--------------------------------------------------------------- Error Totals --
-------------------------------------------------------------------------------
select
    ErrorCounts.Entity,
    ErrorCounts.ImportStatus,
    ErrorCounts.Error,
    ErrorCounts.Count
from
    (
        select
            ImportStatus = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Entity = 'Documents',
            EntitySortOrder = 1,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'
        group by
            INTEGR_REC_STATUS,
            INTEGR_REC_ERROR

    union all

        select
            ImportStatus = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Entity = 'Revisions',
            EntitySortOrder = 2,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'
        group by
            INTEGR_REC_STATUS,
            INTEGR_REC_ERROR

    union all

        select
            ImportStatus = INTEGR_REC_STATUS,
            Error = INTEGR_REC_ERROR,
            Entity = 'RevisionFiles',
            EntitySortOrder = 3,
            Count = count(*)
        from
            dbo.ltbl_Import_DTS_DCS_RevisionFiles with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'
        group by
            INTEGR_REC_STATUS,
            INTEGR_REC_ERROR

    ) ErrorCounts
order by
    EntitySortOrder,
    ImportStatus,
    Error

-------------------------------------------------------------------------------
--------------------------------------------------------------- Error Detail --
-------------------------------------------------------------------------------
select
    Domain,
    DocumentID,
    Statuses = '['+string_agg(EntityImportStatus, ',')+']',
    Errors = '['+string_agg(EntityError, ',')+']',
    LinkPattern
from
    (
        select
            Domain = DCS_Domain,
            DocumentID = DCS_DocumentID,
            EntityImportStatus = '{"Document": "' + INTEGR_REC_STATUS + '"}',
            EntityError = '{"Document": "' + INTEGR_REC_ERROR + '"}',
            LinkPattern = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";A2;"&DocID=";B2);"Open in Pims")'
        from
            dbo.ltbl_Import_DTS_DCS_Documents with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'

    union all

        select      
            Domain = DCS_Domain,
            DocumentID = DCS_DocumentID,
            EntityImportStatus = '{"Revision": "' + INTEGR_REC_STATUS + '"}',
            EntityError = '{"Revision": "' + INTEGR_REC_ERROR + '"}',
            LinkPattern = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";A2;"&DocID=";B2);"Open in Pims")'
        from
            dbo.ltbl_Import_DTS_DCS_Revisions with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'

    union all

        select      
            Domain = DCS_Domain,
            DocumentID = DCS_DocumentID,
            EntityImportStatus = '{"RevisionFile": "' + INTEGR_REC_STATUS + '"}',
            EntityError = '{"RevisionFile": "' + INTEGR_REC_ERROR + '"}',
            PimsLink = '=HYPERLINK(CONCAT("https://pims.akerbp.com/dcs-documents-details?Domain=";A2;"&DocID=";B2);"Open in Pims")'
        from
            dbo.ltbl_Import_DTS_DCS_RevisionFiles with (nolock)
        where
            INTEGR_REC_GROUPREF = @groupRef
            and INTEGR_REC_STATUS like '%FAIL%'

    ) DocumentsErrors
group by
    Domain,
    DocumentID,
    LinkPattern
order by
    Domain,
    DocumentID,
    LinkPattern