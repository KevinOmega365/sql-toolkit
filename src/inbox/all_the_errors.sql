/**
 * All the errors
 */

-------------------------------------------------------------------------------

DECLARE @ProblemRevisionsDocuments TABLE (
    Domain NVARCHAR(128),
    DocumentID NVARCHAR(50),
    DocumentExists BIT,
    DocumentHyperlink NVARCHAR(256),
    DocumentStatus NVARCHAR(50),
    DocumentError NVARCHAR(MAX),
    DocumentValidation NVARCHAR(MAX),
    DocumentQuality NVARCHAR(MAX),
    DocumentScope NVARCHAR(MAX),
    Revision NVARCHAR(50),
    RevisionExists BIT,
    RevisionStatus NVARCHAR(50),
    RevisionError NVARCHAR(MAX),
    RevisionValidation NVARCHAR(MAX),
    RevisionScope NVARCHAR(MAX)
)

-------------------------------------------------------------------------------
-- Insert Akso-issues
INSERT INTO @ProblemRevisionsDocuments (
    Domain,
    DocumentID,
    DocumentExists,
    DocumentStatus,
    DocumentError,
    Revision,
    RevisionExists,
    RevisionStatus,
    RevisionError
)
EXEC [dbo].[lstp_Import_ProArc_ProblemRevisionsDocuments] 1

-- Insert Munin-Aibel issues    
INSERT INTO @ProblemRevisionsDocuments (
    Domain,
    DocumentID,
    DocumentExists,
    DocumentStatus,
    DocumentError,
    Revision,
    RevisionExists,
    RevisionStatus,
    RevisionError
)
EXEC [dbo].[lstp_Import_MuninAibel_ProblemRevisionsDocuments] 1

-------------------------------------------------------------------------------

select *
from @ProblemRevisionsDocuments