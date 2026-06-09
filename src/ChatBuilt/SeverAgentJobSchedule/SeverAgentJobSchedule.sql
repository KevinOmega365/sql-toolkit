/* with Copilot for JobSchedule*/

DECLARE @NamePattern nvarchar(max) = '%maintain%standard%roles%';

SELECT
    Jobs.name AS JobName,
    Category.name AS Category,
    Steps.step_id,
    Steps.step_name,
    Steps.subsystem,
    Steps.command,
    Steps.database_name,
    Schedules.JobSchedule
FROM
    msdb.dbo.sysjobs AS Jobs
    LEFT JOIN msdb.dbo.syscategories AS Category
        ON Jobs.category_id = Category.category_id
    LEFT JOIN msdb.dbo.sysjobsteps AS Steps
        ON Jobs.job_id = Steps.job_id
    LEFT JOIN msdb.dbo.sysjobschedules AS JobsSchedules
        ON Jobs.job_id = JobsSchedules.job_id
    OUTER APPLY (
        SELECT
            JobSchedule =
                CASE S.freq_type
                    -------------------------------------------------------------------
                    -- 1 = One time
                    -------------------------------------------------------------------
                    WHEN 1 THEN
                        'One time on ' +
                        STUFF(STUFF(CONVERT(char(8), S.active_start_date), 5, 0, '-'), 8, 0, '-') +
                        ' at ' +
                        STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), S.active_start_time), 6), 3, 0, ':'), 6, 0, ':')

                    -------------------------------------------------------------------
                    -- 4 = Daily
                    -------------------------------------------------------------------
                    WHEN 4 THEN
                        'Every ' + CAST(S.freq_interval AS varchar(10)) + ' day(s) at ' +
                        STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), S.active_start_time), 6), 3, 0, ':'), 6, 0, ':')

                    -------------------------------------------------------------------
                    -- 8 = Weekly
                    -------------------------------------------------------------------
                    WHEN 8 THEN
                        'Every ' + CAST(S.freq_recurrence_factor AS varchar(10)) + ' week(s) on ' +
                        (
                            SELECT STRING_AGG(DayName, ', ')
                            FROM (
                                SELECT CASE WHEN S.freq_interval & 1   = 1 THEN 'Sunday'    END AS DayName UNION ALL
                                SELECT CASE WHEN S.freq_interval & 2   = 2 THEN 'Monday'    END UNION ALL
                                SELECT CASE WHEN S.freq_interval & 4   = 4 THEN 'Tuesday'   END UNION ALL
                                SELECT CASE WHEN S.freq_interval & 8   = 8 THEN 'Wednesday' END UNION ALL
                                SELECT CASE WHEN S.freq_interval & 16  = 16 THEN 'Thursday'  END UNION ALL
                                SELECT CASE WHEN S.freq_interval & 32  = 32 THEN 'Friday'    END UNION ALL
                                SELECT CASE WHEN S.freq_interval & 64  = 64 THEN 'Saturday'  END
                            ) AS Days
                            WHERE DayName IS NOT NULL
                        ) +
                        ' at ' +
                        STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), S.active_start_time), 6), 3, 0, ':'), 6, 0, ':')

                    -------------------------------------------------------------------
                    -- 16 = Monthly
                    -------------------------------------------------------------------
                    WHEN 16 THEN
                        'Day ' + CAST(S.freq_interval AS varchar(10)) +
                        ' of every ' + CAST(S.freq_recurrence_factor AS varchar(10)) + ' month(s) at ' +
                        STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), S.active_start_time), 6), 3, 0, ':'), 6, 0, ':')

                    -------------------------------------------------------------------
                    -- 32 = Monthly (relative)
                    -------------------------------------------------------------------
                    WHEN 32 THEN
                        CASE S.freq_relative_interval
                            WHEN 1  THEN 'First '
                            WHEN 2  THEN 'Second '
                            WHEN 4  THEN 'Third '
                            WHEN 8  THEN 'Fourth '
                            WHEN 16 THEN 'Last '
                        END +
                        CASE S.freq_interval
                            WHEN 1  THEN 'Sunday'
                            WHEN 2  THEN 'Monday'
                            WHEN 3  THEN 'Tuesday'
                            WHEN 4  THEN 'Wednesday'
                            WHEN 5  THEN 'Thursday'
                            WHEN 6  THEN 'Friday'
                            WHEN 7  THEN 'Saturday'
                            WHEN 8  THEN 'Day'
                            WHEN 9  THEN 'Weekday'
                            WHEN 10 THEN 'Weekend day'
                        END +
                        ' of every ' + CAST(S.freq_recurrence_factor AS varchar(10)) + ' month(s) at ' +
                        STUFF(STUFF(RIGHT('000000' + CONVERT(varchar(6), S.active_start_time), 6), 3, 0, ':'), 6, 0, ':')

                    -------------------------------------------------------------------
                    -- 64 = Agent start
                    -------------------------------------------------------------------
                    WHEN 64 THEN 'When SQL Server Agent starts'

                    -------------------------------------------------------------------
                    -- 128 = Idle
                    -------------------------------------------------------------------
                    WHEN 128 THEN 'When the computer is idle'

                    ELSE 'Unknown schedule'
                END,
            S.freq_type,
            S.freq_interval,
            S.freq_subday_type,
            S.freq_subday_interval,
            S.freq_relative_interval,
            S.freq_recurrence_factor
        FROM
            msdb.dbo.sysschedules AS S
        WHERE
            JobsSchedules.schedule_id = S.schedule_id
    ) Schedules
WHERE
    Jobs.name LIKE @NamePattern
ORDER BY
    Jobs.name,
    Steps.step_id;
