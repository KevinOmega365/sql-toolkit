
declare @problemDocumentRevisions table (
    EmailDate date,
    ItemNumber int,
    Domain char(3),
    DocumentID nvarchar(128),
    Revision nvarchar(2),
    RevisionMissing nvarchar(64),
    DocumentError nvarchar(256),
    RevisionError nvarchar(256)
)

insert into @problemDocumentRevisions
values
('2023-11-28', '1','181','16323-1-R-KA-0001','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-11-28', '2','181','DN02-4500318888-M-KA-0003','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (KA, NULL) in DCS Configuration for domain (181)'),
('2023-11-28', '3','181','DN02-4500318888-Q-TB-0002','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-11-28', '4','181','DN02-4500318888-R-DS-0001','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (DS, NULL) in DCS Configuration for domain (181)'),
('2023-11-28', '5','181','DN02-4500318888-R-DS-0002','02','Missing revision 02 in Pims','','Missing DocumentType-Step combination (DS, NULL) in DCS Configuration for domain (181)'),
('2023-11-28', '6','181','DN02-4500318888-R-XS-0001-01','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (XS, NULL) in DCS Configuration for domain (181)'),
('2023-11-29', '1','181','16323-1-R-KA-0001','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-11-29', '2','181','DN02-4500318888-M-KA-0003','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (KA, NULL) in DCS Configuration for domain (181)'),
('2023-11-29', '3','181','DN02-4500318888-Q-TB-0002','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-11-29', '4','181','DN02-4500318888-R-DS-0001','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (DS, NULL) in DCS Configuration for domain (181)'),
('2023-11-29', '5','181','DN02-4500318888-R-DS-0002','02','Missing revision 02 in Pims','','Missing DocumentType-Step combination (DS, NULL) in DCS Configuration for domain (181)'),
('2023-11-29', '6','181','DN02-4500318888-R-XS-0001-01','01','Missing revision 01 in Pims','','Missing DocumentType-Step combination (XS, NULL) in DCS Configuration for domain (181)'),
('2023-11-30', '1','181','16323-1-R-KA-0001','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-11-30', '2','181','DN02-4500318888-Q-TB-0002','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-12-01', '1','181','16323-1-R-KA-0001','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-12-01', '2','181','17801-R-KA-0002','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-12-01', '3','181','17801-R-LA-0002','02','Missing revision 02 in Pims','','FAILED: Updating revisions from MuninAibel for domain: 181. ERROR:---- Document is currently being reviewed. Please wait for the review to be closed before uploading a new revision. ----'),
('2023-12-01', '4','181','DN02-4500318888-Q-TB-0002','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files'),
('2023-12-01', '5','181','DN02-4500322888-L-MB-0001','02','Missing revision 02 in Pims','','FAILED: Updating revisions from MuninAibel for domain: 181. ERROR:---- Document is currently being reviewed. Please wait for the review to be closed before uploading a new revision. ----')

/**
 * Document recurances
 */
select
    DocumentID,
    Revision,
    Recurances = count(*),
    RecuranceDates = string_agg(EmailDate, ', ') within group (order by EmailDate desc),
    UniqueErrors = count(distinct RevisionError),
    ErrorMessage = max(RevisionError)
from
    @problemDocumentRevisions
group by
    DocumentID,
    Revision
order by
    DocumentID,
    Revision

/**
 * Everything
 */
select * from @problemDocumentRevisions