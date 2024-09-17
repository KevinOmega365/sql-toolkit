# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### DTS - DCS Overview

* [PipelinesStartTimes.sql](src/dcs_integration/PipelinesStartTimes.sql): Pipeline start times.

### Check up on import status of particular documents

* [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql): find whether a set of documents and revisions are present in the import data and/or in Pims DCS.
* [PastedDocumentRevisions.js](src/dcs_integration/PastedDocumentRevisions.js): transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```

### Revisions missing files

* [CheckRevisionsWithoutFiles.sql](src/reporting/CheckRevisionsWithoutFiles.sql): get a quick yes/no on metadata and "physical" file existence

## Checking New Pipelines

### Counts and Data Quality

* [DataCounts_DTS.sql](src/pipeline_development/DataCounts_DTS.sql): Quick counts across tables import tables
* [DataCoverageRatioPercentAndSample.sql](src/pipeline_development/DataCoverageRatioPercentAndSample.sql): Data coverage and sample

### New Changes to document profiles

* [ChangeCountsPivot_Dynamic.sql](src/dts_fdm_reporting/ChangeCountsPivot_Dynamic.sql): Column change aggregates
* [ChangesPerColumn.sql](src/dts_fdm_reporting/ChangesPerColumn.sql): Column change aggregates with to-from values
* [ChangesPerDocument_Valhall_Sundry.sql](src/dts_fdm_reporting/ChangesPerDocument_Valhall_Sundry.sql): Valhall specific document change details
* [ChangesPerDocument_Valhall_Title.sql](src/dts_fdm_reporting/ChangesPerDocument_Valhall_Title.sql): Valhall specific document title change details
* [ChangesPerDocument_Valhall_VoidedDate.sql](src/dts_fdm_reporting/ChangesPerDocument_Valhall_VoidedDate.sql): Valhall specific document voided date change details

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

Code by ChatGPT (prompt: "Could you write a PowerShell script to search for filenames that contain a given string for the current folder and recursively for all subfolders?")
