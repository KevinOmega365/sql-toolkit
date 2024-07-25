# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### Check up on import status of particular documents

Find whether a set of documents and revisions are present in the import data and/or in Pims DCS with [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql).

You can use [PastedDocumentRevisions.js](C:\Users\Kevin\Documents\GitHub\sql-toolkit\src\dcs_integration\PastedDocumentRevisions.js) to transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```
