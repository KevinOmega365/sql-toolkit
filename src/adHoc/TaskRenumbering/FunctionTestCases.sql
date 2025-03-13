declare @Output table
(
    SequenceOrder nvarchar(15)
)
insert into @Output
values
('1'),
('42'),
('3'),
('1.2.3'),
('1.2'),
('4.22.44.1'),
('99.99.99.99')

select
    SortOrder = [dbo].[afnc_Integrations_GetSortOrder](SequenceOrder),
    SequenceOrder
from
    @Output
for
    json auto
