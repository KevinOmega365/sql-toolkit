declare @ExampleJsonTableToUnpack table (
    JsonData nvarchar(max)
)

insert into @ExampleJsonTableToUnpack
values
    ('{"d":{"results":[{"name":"Gwari"},{"name":"Mali"},{"name":"Gwali"}]}}'),
    ('{"d":{"results":[{"name":"Furi"},{"name":"Kilmul"},{"name":"Anzin"}]}}'),
    ('{"d":{"results":[{"name":"Bifar"},{"name":"Dinain"},{"name":"Sanzir"}]}}')

select
    DwarfName = json_value(UnpackedRecords.value, '$.name')
from
    @ExampleJsonTableToUnpack RawImport
    cross apply openjson(RawImport.JsonData, '$.d.results') UnpackedRecords