# sql-toolkit

SQL Snippets (mostly for Omega365 Appframe Databases)

## Quick Links

### Revisions missing files

* [CheckRevisionsWithoutFiles.sql](src/reporting/CheckRevisionsWithoutFiles.sql): get a quick yes/no on metadata and "physical" file existence
* [CorrelatedFileErrorsLogErrors.sql](src/adHoc/FileNotFoundErrors/CorrelatedFileErrorsLogErrors.sql): REST assembly errors with corresponding DocumentID and Revision from the import records

### DTS - DCS Overview

* [PipelinesStartTimes.sql](src/dcs_integration/PipelinesStartTimes.sql): Pipeline start times.

### Check up on import status of particular documents

* [CheckDtsDocumentImport.sql](src/dcs_integration/CheckDtsDocumentImport.sql): find whether a set of documents and revisions are present in the import data and/or in Pims DCS.
* [PastedDocumentRevisions.js](src/dcs_integration/PastedDocumentRevisions.js): transform date-documentNo-revision tab-spaced lists (pasted from Excel) into SQL ```VALUES``` tuples like ```('YOUR_DOCUMENT_NUMBER', 'YOUR_REVISION')```

## 

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
