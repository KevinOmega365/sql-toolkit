
declare @RowsNumbers table (
    c char,
    n tinyint
)

insert into @RowsNumbers
values
    ('a', 1),
    ('a', 2),
    ('a', 3),
    ('b', 1),
    ('b', 2),
    ('b', 3),
    ('c', 1),
    ('c', 2),
    ('c', 3)

select r = row_number() over(partition by n order by c), c, n from @RowsNumbers order by c, n
select r = row_number() over(partition by c order by n), c, n from @RowsNumbers order by c, n