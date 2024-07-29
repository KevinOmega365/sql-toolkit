# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### Check up on import status of particular documents

Find whether a set of documents and revisions are present in the import data and/or in Pims DCS with [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql).

You can use [PastedDocumentRevisions.js](src/dcs_integration/PastedDocumentRevisions.js) to transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```

### Checking DTS against FDM

* [AggregateCountsDocsRevsFiles.sql](src/dts_fdm_reporting/AggregateCountsDocsRevsFiles.sql): status and trace and counts for documents, revisions and files not found in the DTS import. Note that missing revisions are only counted for documents common to both imports. Similarly, files are only counted for revisions that are in both the DTS and FDM.
* [DocumentCounts.sql](src/dts_fdm_reporting/DocumentCounts.sql): Listing of missing documents
* [RevisionCounts.sql](src/dts_fdm_reporting/RevisionCounts.sql): ...
* [FileCounts.sql](src/dts_fdm_reporting/FileCounts.sql): ...

### New Changes to document profiles

* [ChangeCountsPivot_Dynamic.sql](src/dts_fdm_reporting/ChangeCountsPivot_Dynamic.sql): Column change aggregates
* [ChangesPerColumn.sql](src/dts_fdm_reporting/ChangesPerColumn.sql): Column change aggregates with to-from values
