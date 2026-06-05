SELECT 
    j.job_id,
    j.name AS JobName,
    c.name AS Category,
    s.step_id,
    s.step_name,
    s.subsystem,
    s.command,
    s.database_name,
    s.last_run_outcome,
    s.last_run_duration,
    s.last_run_date,
    s.last_run_time
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.syscategories AS c 
    ON j.category_id = c.category_id
LEFT JOIN msdb.dbo.sysjobsteps AS s 
    ON j.job_id = s.job_id
ORDER BY j.name, s.step_id;
