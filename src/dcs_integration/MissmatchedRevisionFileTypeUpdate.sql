/*
 * Explore missmatched revision-file Type and Description updating
 */

select Domain = DCS_Domain
into #DomainList
from dbo.ltbl_Import_DTS_DCS_RevisionsFiles with (nolock)
where
    DCS_Domain is not null
    and INTEGR_REC_GROUPREF = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
group by DCS_Domain

-- select * from #DomainList

/*
 * get the duplicated revision-files,
 * with differing DCS Types from the import table
 */
-- select
--     DCS_Domain,
--     DCS_DocumentID,
--     -- activate_link_document =
--     --     '<a href="' +
--     --     '/dcs-documents-details?Domain=' +
--     --     DCS_Domain +
--     --     '&DocID=' +
--     --     DCS_DocumentID +
--     --     '">' +
--     --     'ctrl+click' +
--     --     '</a>',
--     DCS_Revision,
--     DCS_FileRef--,
--     -- DCS_Types = string_agg(DCS_Type, ', ')
-- from
--     dbo.ltbl_Import_DTS_DCS_RevisionsFiles as FR with (nolock)
-- group by
--     DCS_Domain,
--     DCS_DocumentID,
--     DCS_Revision,
--     DCS_FileRef
-- having
--     count(*) > 1
--     and count(distinct DCS_Type) > 1
-- order by
--     DCS_Domain,
--     DCS_DocumentID,
--     DCS_Revision

/*
 * Import file ref duplication counts
 */
-- select
--     FileRefCount,
--     InstanceCount = count(*)
-- from
--     (
--         select
--             FileRefCount = count(*)
--         from
--             dbo.ltbl_Import_DTS_DCS_RevisionsFiles as RF with (nolock)
--             join #DomainList D
--                 on D.Domain = RF.DCS_Domain
--         group by
--             DCS_Domain,
--             DCS_DocumentID,
--             DCS_Revision,
--             DCS_FileRef
--         having
--             count(*) > 1
--             and count(distinct DCS_Type) > 1
--     ) T
-- group by
--     FileRefCount
-- order by
--     FileRefCount desc

/*
 * Get the duplicated revision-files in Pims associated
 *   with the those in the import table and view types
 */
-- select count(*)
-- from
--     dbo.atbl_DCS_RevisionsFiles as RF with (nolock)
--     join #DomainList D
--         on D.Domain = RF.Domain
-- group by
--     RF.Domain,
--     RF.DocumentID,
--     RF.RevisionItemNo,
--     RF.FileRef
-- having
--     count(*) > 1
--     and count(distinct Type) > 1
-- order by
--     RF.Domain,
--     RF.DocumentID,
--     RF.RevisionItemNo

/*
 * Pims file ref duplication counts
 */
-- select
--     FileRefCount,
--     InstanceCount = count(*)
-- from
--     (
--         select
--             FileRefCount = count(*)
--         from
--             dbo.atbl_DCS_RevisionsFiles as RF with (nolock)
--             join #DomainList D
--                 on D.Domain = RF.Domain
--         group by
--             RF.Domain,
--             RF.DocumentID,
--             RF.RevisionItemNo,
--             RF.FileRef
--         having
--             count(*) > 1
--             and count(distinct Type) > 1
--     ) T
-- group by
--     FileRefCount
-- order by
--     FileRefCount desc

/*
 * For a given document revision how are the revision-file DCS Types updated over time
 */
-- declare @Domain nvarchar(128) = N'128'
-- declare @DocumentID nvarchar(100) = N'FPQ-BI674-XD-00505-01'
-- declare @FieldName nvarchar(128) = 'Type' -- 'FileDescription' --
-- SELECT
--     [Source],
--     [Created],
--     [CreatedBy],
--     [FieldName],
--     [FieldValue],
--     [OldValue],
--     [Comments]
-- FROM
--     [dbo].[aviw_DCS_DocumentsLogCrossDomain]
-- WHERE
--     (
--         [Domain] = @Domain
--         AND [DocumentID] = @DocumentID
--         AND [FieldName] like @FieldName
--     )
-- ORDER BY
--     [Created] DESC

/*
 * Write a query to find spurious updates
 *
 * That is when the DCS Type for a record is not matched,
 * but the SET of DCS Types across the duplicated revision-file duplicated FileRefs match
 */
