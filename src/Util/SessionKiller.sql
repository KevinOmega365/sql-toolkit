SELECT
    '-- kill ' + CAST(conn.session_id AS NVARCHAR(MAX)) AS stmt,
    Conn.session_id,
    Sess.host_name,
    Sess.program_name,
    Sess.nt_domain,
    Sess.login_name,
    Sess.cpu_time,
    Sess.logical_reads,
    Sess.status,
    Conn.connect_time
    --, *
FROM
    sys.dm_exec_sessions AS Sess
    JOIN sys.dm_exec_connections AS Conn
        ON Sess.session_id = Conn.session_id
WHERE
    login_name = 'a_kevin'
