
/*
 * Config appDependencies counts
 */
SELECT top 10
    ConfigEntry = D.value,
    InstanceCount = count(*)
FROM
    dbo.stbl_O365_Apps A
    cross apply openjson(Config, '$.appDependencies') D
group by
    D.value
order by
    InstanceCount desc

/*
 * Config key usage counts
 */
-- SELECT top 10
--     ConfigEntry = C.[key],
--     InstanceCount = count(*)
-- FROM
--     dbo.stbl_O365_Apps A
--     cross apply openjson(Config) C
-- group by
--     C.[key]
-- order by
--     InstanceCount desc

/*
 * sample configs
 */
-- SELECT top 10
--     Config
-- FROM
--     dbo.stbl_O365_Apps
-- order by
--     newid()
