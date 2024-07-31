# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### Check up on import status of particular documents

Find whether a set of documents and revisions are present in the import data and/or in Pims DCS with [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql).

You can use [PastedDocumentRevisions.js](src/dcs_integration/PastedDocumentRevisions.js) to transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```

### Checking DTS against FDM

* [AggregateCountsDocsRevsFiles.sql](src/dts_fdm_reporting/AggregateCountsDocsRevsFiles.sql): status and trace and counts for documents, revisions and files not found in the DTS import. Note that missing revisions are only counted for documents common to both imports. Similarly, files are only counted for revisions that are in both the DTS and FDM.
* [MissingFilesDetails.sql](src/dts_fdm_reporting/MissingFilesDetails.sql): details on revision-files not present in the DTS import, that have a file in Pims.

A bit less useful

* [DocumentCounts.sql](src/dts_fdm_reporting/DocumentCounts.sql): Mostly raw counts
* [RevisionCounts.sql](src/dts_fdm_reporting/RevisionCounts.sql): Mostly raw counts
* [FileCounts.sql](src/dts_fdm_reporting/FileCounts.sql): Mostly raw counts

### New Changes to document profiles

* [ChangeCountsPivot_Dynamic.sql](src/dts_fdm_reporting/ChangeCountsPivot_Dynamic.sql): Column change aggregates
* [ChangesPerColumn.sql](src/dts_fdm_reporting/ChangesPerColumn.sql): Column change aggregates with to-from values
* [ChangesPerDocument.sql](src/dts_fdm_reporting/ChangesPerDocument.sql): Each document with "ACTION_UPDATE" with a from and to value for the changing columns
* [ChangesPerDocument_Valhall_Sundry.sql](src/dts_fdm_reporting/ChangesPerDocument_Valhall_Sundry.sql): Valhall specific document change details
* [ChangesPerDocument_Valhall_Title.sql](src/dts_fdm_reporting/ChangesPerDocument_Valhall_Title.sql): Valhall specific document change details
