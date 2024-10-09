
----------------------------------------------------------- reset temp table --
DROP TABLE IF EXISTS #PipelineGroupRefQuerySystem;

------------------------------------------------------- pipeline working set --
declare
    @IvarAasen uniqueidentifier = 'f6c3687c-5511-48f2-98e5-8e84eee9b689',
    @Munin uniqueidentifier = 'e1a66f7c-ab9b-4586-aa71-4b4cab743aa2',
    @Valhall uniqueidentifier = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7',
    @Yggdrasil uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0',
    @EdvardGrieg uniqueidentifier = 'edadd424-81ce-4170-b419-12642f80cfde',
    @Subsea uniqueidentifier = 'fb36536c-db59-4926-952a-5868262a44a5'

declare
    @SourceGroupRef uniqueidentifier = @Valhall

----------------------------------------------- load pipelines query systems --
select
    Name,
    QuerySystem = (
        select
            json_value(StepConfig, '$.QuerySystem')
        from
            dbo.atbl_Integrations_ScheduledTasksConfigGroupTasks Tasks with (nolock)
        where
            StepType = 'API / Query System'
            and Name = 'Import Documents (RAW)'
            and Tasks.GroupRef = Pipelines.PrimKey
    ),
    GroupRef = PrimKey
into
    #PipelineGroupRefQuerySystem
from
    dbo.atbl_Integrations_ScheduledTasksConfigGroups Pipelines with (nolock)
where
    PrimKey in (
        @IvarAasen,
        @Munin,
        @Valhall,
        @Yggdrasil,
        @EdvardGrieg,
        @Subsea
    )

------------------------------------------------------- load template source --
declare
    @SourceQuerySystem nvarchar(max),
    @SourceConfig nvarchar(max)

SELECT
    @SourceQuerySystem = PGQS.QuerySystem,
    @SourceConfig = DI.Config
FROM
    [dbo].[atbl_Integrations_DashboardItems] DI WITH (NOLOCK)
    JOIN dbo.atbl_Integrations_Services AS S WITH (NOLOCK)
        ON S.PrimKey = DI.ServiceRef
    JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG WITH (NOLOCK)
        ON STCG.PrimKey = S.EndpointRef
    JOIN #PipelineGroupRefQuerySystem PGQS WITH (NOLOCK)
        ON PGQS.GroupRef = STCG.PrimKey
WHERE
    PGQS.GroupRef = @SourceGroupRef

------------------------------------------------------- generate new configs --
-- UPDATE DI SET DI.Config = replace(replace(@SourceConfig, @SourceGroupRef, PGQS.GroupRef), @SourceQuerySystem, PGQS.QuerySystem)
SELECT
    PGQS.Name,
    OriginalConfig = DI.Config,
    NewConfig = replace(replace(@SourceConfig, @SourceGroupRef, PGQS.GroupRef), @SourceQuerySystem, PGQS.QuerySystem),
    ConfigCheck = case
        when DI.Config = replace(replace(@SourceConfig, @SourceGroupRef, PGQS.GroupRef), @SourceQuerySystem, PGQS.QuerySystem)
        then 'Match'
        else 'Nope'
        end
FROM
    [dbo].[atbl_Integrations_DashboardItems] DI WITH (NOLOCK)
    JOIN dbo.atbl_Integrations_Services AS S WITH (NOLOCK)
        ON S.PrimKey = DI.ServiceRef
    JOIN dbo.atbl_Integrations_ScheduledTasksConfigGroups STCG WITH (NOLOCK)
        ON STCG.PrimKey = S.EndpointRef
    JOIN #PipelineGroupRefQuerySystem PGQS WITH (NOLOCK)
        ON PGQS.GroupRef = STCG.PrimKey
ORDER BY
    [ServiceTypeID],
    [EndpointName]

------------------------------------------------------------------ reference --

select
    SourceGroupRef = @SourceGroupRef,
    SourceQuerySystem = @SourceQuerySystem

select * from #PipelineGroupRefQuerySystem