declare @odataJson nvarchar(max) = '{
    "$painInThe": "a$$",
    "andArrays": ["wat"]
}'


select isjson = isjson('[[]]')

select
    Dollar = json_value(@odataJson, '$."$painInThe"'),
    AtIndex = json_value(@odataJson, '$.andArrays[0]')