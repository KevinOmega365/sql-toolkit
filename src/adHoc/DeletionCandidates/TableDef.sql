CREATE TABLE [dbo].[ltbl_integrations_DCS_DocsDeletionCandidates]
(
      [PrimKey] [UNIQUEIDENTIFIER] NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_PrimKey] DEFAULT (newid())
    , [Created] [DATETIME2](7) NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_Created] DEFAULT (getutcdate())
    , [CreatedBy] [NVARCHAR](128) NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_CreatedBy] DEFAULT (suser_sname())
    , [Updated] [DATETIME2](7) NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_Updated] DEFAULT (getutcdate())
    , [UpdatedBy] [NVARCHAR](128) NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_UpdatedBy] DEFAULT (suser_sname())
    , [CUT] [BIT] NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_CUT] DEFAULT ((0))
    , [CDL] [BIT] NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_CDL] DEFAULT ((0))
    , [Domain] [NVARCHAR](128) NOT NULL
    , [DocumentID] [NVARCHAR](128) NOT NULL
    , [MirroringDomain] [NVARCHAR](128) NULL
    , [Title] [NVARCHAR](500) NULL
    , [INTEGR_REC_STATUS] [NVARCHAR](50) NOT NULL CONSTRAINT [DF_ltbl_integrations_DCS_DocsDeletionCandidates_INTEGR_REC_STATUS] DEFAULT ('IMPORTED_OK')
    , [INTEGR_REC_ERROR] [NVARCHAR](512) NULL
    , CONSTRAINT [PK_ltbl_integrations_DCS_DocsDeletionCandidates] PRIMARY KEY CLUSTERED ([Domain], [DocumentID])
);