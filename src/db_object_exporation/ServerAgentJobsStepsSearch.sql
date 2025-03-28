
declare @commandPattern nvarchar(max) = '%SharePointList%'

select
    JobID = Jobs.job_id,
    JobName = Jobs.name,
    StepName = Steps.step_name,
    StepCommand = Steps.command
from
    msdb.dbo.sysJobs Jobs
    left join msdb.dbo.sysjobsteps Steps
        on Jobs.job_id = Steps.job_id
where
    Steps.command like @commandPattern
order by
    JobName

-- ref:https://stackoverflow.com/a/50622563/1393179
