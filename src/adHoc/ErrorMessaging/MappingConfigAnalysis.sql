/*
 * Dump the mappings that we have
 */
-- select distinct
--     OldErrorDescription,
--     NewErrorDescription
-- from
--     dbo.atbl_Integrations_Configurations_ErrorMappings with (nolock)
-- order by
--     OldErrorDescription,
--     NewErrorDescription

/*
 * Pattern message deviation
 * Do the same old message patterns map to the same new message
 * This should be empty
 */
-- declare @excludeOneToOneMappings bit = 1
-- select
--     OldErrorDescription,
--     MapsToNewMessageCount = count(distinct NewErrorDescription)
-- from
--     dbo.atbl_Integrations_Configurations_ErrorMappings with (nolock)
-- group by
--     OldErrorDescription
-- having
--     count(distinct NewErrorDescription) > 1
--     or @excludeOneToOneMappings = 0
-- order by
--     OldErrorDescription

/*
 * Per pattern count
 */
-- select
--     OldErrorDescription,
--     TotalUsageCount = count(*),
--     TableUsageCount = count(distinct TableName),
--     TableListJson = '["' + (
--         select string_agg(TableName, '", "') 
--         from (
--             select distinct TableName
--             from dbo.atbl_Integrations_Configurations_ErrorMappings with (nolock)
--             where OldErrorDescription = E.OldErrorDescription
--         ) Foo
--     ) + '"]',
--     GroupRefUsageCount = count(distinct GroupRef),
--     GroupRefList = '["' + (
--         select string_agg(GroupRefString, '", "') 
--         from (
--             select distinct GroupRefString = cast(GroupRef as nchar(36))
--             from dbo.atbl_Integrations_Configurations_ErrorMappings with (nolock)
--             where OldErrorDescription = E.OldErrorDescription
--         ) Bar
--     ) + '"]'
-- from
--     dbo.atbl_Integrations_Configurations_ErrorMappings as E with (nolock)
-- group by
--     OldErrorDescription
-- order by
--     OldErrorDescription


/*
 * Per pipeline mapping count
 */
-- select
--     MappingCount = count(*),
--     Pipeline = (
--         select
--             Name
--         from
--             dbo.atbl_Integrations_ScheduledTasksConfigGroups as STCG with (nolock)
--         where
--             STCG.PrimKey = E.GroupRef
--     ),
--     GroupRef
-- from
--     dbo.atbl_Integrations_Configurations_ErrorMappings as E with (nolock)
-- group by
--     GroupRef

/*
 * Total entry count
 */
-- select TotalCount = count(*) from dbo.atbl_Integrations_Configurations_ErrorMappings as [C] with (nolock)

/*
 * Random sample
 */
SELECT TOP 50 * FROM dbo.atbl_Integrations_Configurations_ErrorMappings AS [C] WITH (NOLOCK) ORDER BY NEWID()
