declare
	@login nvarchar(128) = '%',
	@databaseName nvarchar(128) = '%'

	SELECT
	'kill ' + cast(session_id as nvarchar(max)) murder,
	session_id, DB_NAME(database_id) DatabaseName,
	cpu_time, memory_usage,
	login_name,
	'', *
FROM sys.dm_exec_sessions
where login_name like @login
and DB_NAME(database_id) like @databaseName
