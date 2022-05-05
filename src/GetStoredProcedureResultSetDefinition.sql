DECLARE @sql NVARCHAR(MAX) = N'EXEC sp_fkeys ''atbl_DCS_RevisionsFiles'';';
SELECT
    name,
    system_type_name
FROM
    sys.dm_exec_describe_first_result_set(@sql, NULL, 1)
WHERE
    is_hidden = 0
