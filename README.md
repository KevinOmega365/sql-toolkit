# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### Revisions missing files

* [CheckRevisionsWithoutFiles.sql](src/reporting/CheckRevisionsWithoutFiles.sql): get a quick yes/no on metadata and "physical" file existence
* [CorrelatedFileErrorsLogErrors.sql](src/adHoc/FileNotFoundErrors/CorrelatedFileErrorsLogErrors.sql): REST assembly errors with corresponding DocumentID and Revision from the import records

### Pipeline Overview

* [PipelinesStartTimes.sql](src/dcs_integration/PipelinesStartTimes.sql): Pipeline start times.
* [UpdateSqlStepTimeout.sql](/src/adHoc/UnifyPipelines/UpdateSqlStepTimeout.sql): Pipeline SQL step timeouts review and update

### Check up on import status of particular documents

* [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql): find whether a set of documents and revisions are present in the import data and/or in Pims DCS.
* [PastedDocumentRevisions.js](src/dcs_integration/PastedDocumentRevisions.js): transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```
* [CheckDocRevFileWithLog.sql](src/dcs_integration/CheckDocRevFileWithLog.sql): Detailed check pulling in file and log data

## Quality Revisions without Files
* [PipelineErrorsInOutPerBatch.sql](src/reporting/PipelineErrorsInOutPerBatch.sql): Errors In and Out
* [ErrorsOverTime.sql](src/dcs_integration/ErrorsOverTime.sql): Errors that persist over pipeline runs
* [CheckRevisionsWithoutFilesMetadataAndLog.sql](src/dcs_integration/CheckRevisionsWithoutFilesMetadataAndLog.sql): Related log and metadata details for missing files errors on revsions
* [CheckRevisionsWithoutFilesMetadataAndLogWithErrorsOverTime.sql](src/dcs_integration/CheckRevisionsWithoutFilesMetadataAndLogWithErrorsOverTime.sql): All together: logs, metadata, error persistence

## Orphaned DB Objects

Objects created by the integration, but nolonger present in the source data

* [DTS_DocumentOrphans.sql](src/adHoc/Orphans/DTS_DocumentOrphans.sql): Documents counts, lists and links
* [DTS_RevisionOrphans.sql](src/adHoc/Orphans/DTS_RevisionOrphans.sql): Revisions counts
* [DTS_FileOrphans.sql](src/adHoc/Orphans/DTS_FileOrphans.sql): Files counts, lists and links

## Data Coverage

* [DataCoverageRatioPercentAndSample.sql](src/pipeline_development/): check percents of non-null column data and sample values

## Finding scripts in this dumster fire

Use the search functionality in github.com ```repo:KevinOmega365/sql-toolkit YOUR_SEARCH_TERMS_HERE```

If you have a local copy of this repository you can search for files by name with PowerShell

Example filesnames containing "file"

``` PowerShell
# Define the string to search for
$searchString = "file"

# Get the current directory
$currentDirectory = Get-Location

# Use Get-ChildItem to recursively search for files containing the search string in their name
Get-ChildItem -Path $currentDirectory -Recurse -File | Where-Object { $_.Name -like "*$searchString*" } | Select-Object FullName
```

Code by ChatGPT (prompt: "Could you write a PowerShell script to search for filenames that contain a given string for the current folder and recursively for all subfolders?"

## Active Link Bookmarklet

Usage: Create a bookmark and set the next line as the URL

``` JavaScript
javascript:(()=>{[...document.querySelector("iframe.active").contentWindow.document.querySelectorAll('[data-field^=activate_link]')].forEach(e=>{const p=e.parentElement;p.innerHTML=e.value;});})();
```

If a colum alias starts with "activate_link" the text in the column will rendered as html

NB: ctrl-click to open in a new tab!

``` SQL
SELECT TOP 10
    -- live links in af-db-manager
    activate_link_document =
        '<a href="' +
        'https://pims.akerbp.com/dcs-documents-details?Domain=' +
        D.Domain +
        '&DocID=' +
        D.DocumentID +
        '">' +
        D.DocumentID +
        '</a>'
FROM
    dbo.atbl_DCS_Documents AS D WITH (NOLOCK)
ORDER BY
    NEWID()
```
