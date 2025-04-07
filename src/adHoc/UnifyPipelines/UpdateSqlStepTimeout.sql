declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde'

declare @GroupRef nvarchar(36) = @Munin -- '%'

/*
 * SQL tasks timeouts
 */
select
    TaskRef = Step.Primkey,
    Step.SequenceOrder,
    Step.Name,
    StoredProcedure = json_value(Step.StepConfig, '$.Procedure'),
    Timeout = json_value(Step.StepConfig, '$.Timeout')
from 
    dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Step WITH (NOLOCK)
    join dbo.atbl_Integrations_ScheduledTasksConfigGroups AS Pipeline WITH (NOLOCK)
        on Pipeline.PrimKey = Step.GroupRef
where
    Pipeline.Primkey LIKE @GroupRef
    and Step.StepType = 'Stored Procedure'
order by
    Step.SortOrder,
    Step.Name

/*
 * Set timeout
 */
-- declare @TaskRef nvarchar(36) = '68efb42f-c963-4859-98cd-5448242273a1' -- '%'
-- -- update Step set
-- select CurrentTimeout = json_value(Step.StepConfig, '$.Timeout'),
--     StepConfig = json_modify(Step.StepConfig, '$.Timeout', 2400)
-- from 
--     dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks AS Step WITH (NOLOCK)
-- where
--     Step.GroupRef LIKE @GroupRef
--     and Step.PrimKey LIKE @TaskRef
--     and Step.StepType = 'Stored Procedure'
