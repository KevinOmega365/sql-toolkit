
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
('2023-11-28', '1','181','16323-1-R-KA-0001','02','Missing revision 02 in Pims','','Quallity Failure: Revision without Files')
-- , ...

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