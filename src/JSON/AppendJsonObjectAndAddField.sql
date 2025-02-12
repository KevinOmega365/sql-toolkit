declare
    @message nvarchar(max) = 'YOUR_MESSAGE_HERE',
    @testJson nvarchar(max),
    @assertJson nvarchar(max)

-------------------------------------------------------------------------------
-------------------------------------------------------------------- testing --
-------------------------------------------------------------------------------

/*
 * existing trace with error with existing field
 */
select
    @testJson = '{"error":{"toFix":"Update the domain configuration"}}',
    @assertJson = '{"error":{"toFix":"Update the domain configuration","originalErrorMessage":"' + @message + '"}}'
select
    Test = case
        when
            @assertJson = json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message))
        then
            'Pass'
        else
            'Fail'
    end,
    json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message)),
    @testJson,
    @assertJson

/*
 * existing trace without "error"
 */
select
    @testJson = '{"scope":["Wayout"]}',
    @assertJson = '{"scope":["Wayout"],"error":{"originalErrorMessage":"' + @message + '"}}'
select
    Test = case
        when
            @assertJson = json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message))
        then
            'Pass'
        else
            'Fail'
    end,
    json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message)),
    @testJson,
    @assertJson

/*
 * null trace
 */
select
    @testJson = null,
    @assertJson = '{"error":{"originalErrorMessage":"' + @message + '"}}'
select
    Test = case
        when
            @assertJson = json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message))
        then
            'Pass'
        else
            'Fail'
    end,
    json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message)),
    @testJson,
    @assertJson

/*
 * empty string trace
 */
select
    @testJson = '',
    @assertJson = '{"error":{"originalErrorMessage":"' + @message + '"}}'
select
    Test = case
        when
            @assertJson = json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message))
        then
            'Pass'
        else
            'Fail'
    end,
    json_modify(isnull(nullif(@testJson, ''), '{}'), '$.error', json_modify(isnull(json_query(isnull(nullif(@testJson, ''), '{}'), '$.error'), '{}'), '$.originalErrorMessage', @message)),
    @testJson,
    @assertJson
