declare @fixedFiles table (
    Id uniqueidentifier,
    documentNumber nvarchar(128),
    revision nvarchar(128),
    md5hash nvarchar(128),
    fileType nvarchar(128),
    fileName nvarchar(128),
    sourceId uniqueidentifier
)

insert into @fixedFiles
SELECT '92DCAEFC-15DA-437E-8B5D-9DAEEA165153', 'AAR-SIE-I-LA-00003', '01', '8BA351553F247FCC5CBE27D8F742EE2D', 'PDF', '12386968.PDF', '19E0A69A-0EB1-4F1A-9C90-C9D9705A92BA' UNION ALL
SELECT 'AC09E408-B2A5-4BEF-91E9-8E8DDA2FB5F3', 'AAR-SIE-I-LA-00014', '01', '10F12047C02659BFE7A18A54A9CBF4A2', 'PDF', '12386974.PDF', '19E0A69A-0EB1-4F1A-9C90-C9D9705A92BA' -- ...

insert into dbo.ltbl_Import_DCS_DCS_FileRepairRecords (
    object_guid,
    DCS_DocumentID,
    DCS_Revision,
    md5hash,
    DCS_FileName,
    DCS_Import_ExternalUniqueRef
)
select
    object_guid = Id, -- uniqueidentifier,
    DCS_DocumentID = documentNumber, -- nvarchar(128),
    DCS_Revision = revision, -- nvarchar(128),
    md5hash = md5hash, -- nvarchar(128),
    DCS_FileName = fileName, -- nvarchar(128)
    DCS_Import_ExternalUniqueRef = 'DTS:' + cast(Id as char(36))
from
    @fixedFiles

select
    allFiles = count(*),
    distinctIds = count(distinct Id),
    distinctMD5s = count(distinct md5hash)
from
    @fixedFiles
