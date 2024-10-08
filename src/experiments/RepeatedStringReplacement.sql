declare @mapping nvarchar(max) = '[
    {"pattern": "W", "replacement": "D"},
    {"pattern": "H", "replacement": "O"},
    {"pattern": "A", "replacement": "P"},
    {"pattern": "T", "replacement": "E"}
]'

declare @expression nvarchar(max) = 'WHAT'
declare @workspace nvarchar(max) = @expression

declare @n int = (select count(*) from openjson(@mapping))

declare @pattern nvarchar(max)
declare @replacement nvarchar(max)

declare @i int = 0
while @i < @n
begin
    select
        @pattern = (select json_value(value, '$.pattern') from openjson(@mapping) where [key] = @i),
        @replacement = (select json_value(value, '$.replacement') from openjson(@mapping) where [key] = @i)

    print @pattern + ' : ' + @replacement

    set @workspace = replace(@workspace, @pattern, @replacement)

    set @i = @i + 1
end

select @expression + ' : ' + @workspace AS Replacement