SELECT 
    j.job_id,
    j.name AS JobName,
    s.schedule_id,
    s.name AS ScheduleName,
    s.enabled AS ScheduleEnabled,
    s.freq_type,
    s.freq_interval,
    s.freq_subday_type,
    s.freq_subday_interval,
    s.freq_relative_interval,
    s.freq_recurrence_factor,
    s.active_start_date,
    s.active_end_date,
    s.active_start_time,
    s.active_end_time,
    js.next_run_date,
    js.next_run_time
FROM msdb.dbo.sysjobs AS j
LEFT JOIN msdb.dbo.sysjobschedules AS js 
    ON j.job_id = js.job_id
LEFT JOIN msdb.dbo.sysschedules AS s 
    ON js.schedule_id = s.schedule_id
ORDER BY j.name, s.name;
