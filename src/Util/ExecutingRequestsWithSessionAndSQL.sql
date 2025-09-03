/*
 * actively executing requests
 * with session and connection information,
 * along with the text of the SQL query
 */
SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    c.connect_time,
    r.start_time AS request_start_time,
    r.status AS request_status,
    r.command,
    DB_NAME(r.database_id) AS database_name,
    st.text AS sql_query_text
FROM
    sys.dm_exec_sessions AS s
INNER JOIN
    sys.dm_exec_connections AS c ON s.session_id = c.session_id
INNER JOIN
    sys.dm_exec_requests AS r ON s.session_id = r.session_id
CROSS APPLY
    sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE
    s.is_user_process = 1 -- Filter for user processes only
    AND r.status = 'running' -- Filter for actively running requests
ORDER BY
    r.start_time;
