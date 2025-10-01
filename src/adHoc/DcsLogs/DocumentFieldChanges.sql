
/*
 * Document change counts by Domain and FieldName
 */
-- SELECT 
--     Domain,
--     N'Document' AS [Source],
--     FieldName,
--     Count = count(*)
-- FROM
--     [dbo].[atbl_DCS_DocumentsLog] with (nolock)
-- where
--     Created > cast(getdate() as date)
--     and CreatedBy = 'af_Integrations_ServiceUser'
--     and Domain in ('128', '187')
-- group by
--     Domain,
--     FieldName
-- order by
--     Domain,
--     FieldName

/*
 * Change counts for a FieldName
--  */
-- select
--     Domain,
--     DocumentID,
--     FieldName,
--     FieldValue,
--     OldValue
-- from
--     [dbo].[atbl_DCS_DocumentsLog] with (nolock)
-- where
--     Created > cast(getdate() as date)
--     and CreatedBy = 'af_Integrations_ServiceUser'
--     and Domain = '175'
--     and FieldName = 'Area'
-- order by
--     Domain,
--     DocumentID

/*
 * Change counts for a FieldName
 */
SELECT
    N'Document' AS [Source],
    FieldName,
    FieldValue,
    OldValue,
    Count = count(*)
FROM
    [dbo].[atbl_DCS_DocumentsLog] with (nolock)
where
    Created > cast(getdate() as date)
    and CreatedBy = 'af_Integrations_ServiceUser'
    and Domain = '175'
    and FieldName = 'Area'

/*
 * Samples
 */
-- SELECT top 50 N'Document' AS [Source], Created, CreatedBy, Domain, DocumentID, FieldName, FieldValue, OldValue, Comments 
-- 	FROM [dbo].[atbl_DCS_DocumentsLog] with (nolock)
-- where
--     Created > cast(getdate() as date)
--     and CreatedBy = 'af_Integrations_ServiceUser'
--     and Domain = '175'
-- SELECT top 50 N'Revision' AS [Source], Created, CreatedBy, Domain, DocumentID, FieldName, FieldValue, OldValue, Comments
-- 	FROM [dbo].[atbl_DCS_RevisionsLog] with (nolock)
-- where
--     Created > cast(getdate() as date)
--     and CreatedBy = 'af_Integrations_ServiceUser'
--     and Domain = '175'
-- SELECT top 50 N'Revisions Files' AS [Source], Created, CreatedBy, Domain, DocumentID, FieldName, FieldValue, OldValue, Comments
-- 	FROM [dbo].[atbl_DCS_RevisionsFilesLog] with (nolock)
-- where
--     Created > cast(getdate() as date)
--     and CreatedBy = 'af_Integrations_ServiceUser'
--     and Domain = '175'
