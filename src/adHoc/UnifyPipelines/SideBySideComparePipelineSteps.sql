/*
 * Compare Pipelines Steps
 */
declare
    @hasStep nvarchar(64) = '',
    @missingStep nvarchar(64) = 'nope'
select
    Count = count(*),
    Step.SequenceOrder,
    Step.Name,
    EdvardGrieg = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|edadd424-81ce-4170-b419-12642f80cfde|%' then @hasStep else @missingStep end),
    MUNIN = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|e1a66f7c-ab9b-4586-aa71-4b4cab743aa2|%' then @hasStep else @missingStep end),
    Valhall = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|564d970e-8b1a-4a4a-913b-51e44d4bd8e7|%' then @hasStep else @missingStep end),
    Subsea = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|fb36536c-db59-4926-952a-5868262a44a5|%' then @hasStep else @missingStep end),
    IvarAasen = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|f6c3687c-5511-48f2-98e5-8e84eee9b689|%' then @hasStep else @missingStep end),
    Yggdrasil = (select case when '|' + string_agg(cast(Step.GroupRef as char(36)), '|') + '|' like '%|efd3449e-3a44-4c38-b0e7-f57ca48cf8b0|%' then @hasStep else @missingStep end)
from 
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Step WITH (NOLOCK)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipeline WITH (NOLOCK)
        on Pipeline.PrimKey = Step.GroupRef
where
    Pipeline.Name LIKE '%dts%docu%'
    and Pipeline.Inactive = 0
group by
    Step.SequenceOrder,
    Step.SortOrder,
    Step.Name
order by
    Step.SortOrder,
    Step.Name
