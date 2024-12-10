/*
 * Start of log messages
 */
--select left(LogMessage, 32)
--from
--	dbo.atbl_AzureAdSync_Log with (nolock)

/*
 * Classification of log messages
 */
--select LogMessageClass, Count = count(*)
--from
--	(
--		select
--			LogMessageClass = case
--				when LogMessage like '{"runId"%' then 'Message'
--				when  LogMessage like '{"@odata.context"%' then 'Data'
--				when  LogMessage like '{"message": {"type": "RUN_START%' then 'StartFlag'
--				when LogMessage like '{"error%' then 'Error'
--				when LogMessage like '{"type":"GRANT%' then 'Grant'
--				when LogMessage like '{"type":"REVOKE%' then 'Revoke'
--				else 'Unclassified' -- left(LogMessage, 32)
--			end
--		from
--			dbo.atbl_AzureAdSync_Log with (nolock)
--	) T
--group by
--	LogMessageClass

/*
 * Explore a message class
 */
--declare @messageClass nvarchar(128) = 'Error'
--select top 100 LogMessageClass, LogMessage
--from
--	(
--		select
--			LogMessageSource = json_value(LogMessage, '$.source'),
--			LogMessage,
--			LogMessageClass = case
--				when LogMessage like '{"runId"%' then 'Message'
--				when  LogMessage like '{"@odata.context"%' then 'Data'
--				when  LogMessage like '{"message": {"type": "RUN_START%' then 'StartFlag'
--				when LogMessage like '{"error%' then 'Error'
--				when LogMessage like '{"type":"GRANT%' then 'Grant'
--				when LogMessage like '{"type":"REVOKE%' then 'Revoke'
--				else 'Unclassified' -- left(LogMessage, 32)
--			end
--		from
--			dbo.atbl_AzureAdSync_Log with (nolock)
--	) T
--where
--	LogMessageClass = @messageClass
--order by
--	newid()

/*
 * Get a run by time
 */
--declare @runHour int = 7
--declare @topOfTheHour bit = 0
--select
--	PrimKey,
--	Created,
--	LogMessageClass,
--	LogMessage
--from
--	(
--		select
--			PrimKey,
--			Created,
--			-- LogMessageSource = json_value(LogMessage, '$.source'),
--			LogMessageClass = case
--				when LogMessage like '{"runId"%' then 'Message'
--				when  LogMessage like '{"@odata.context"%' then 'Data'
--				when  LogMessage like '{"message": {"type": "RUN_START%' then 'StartFlag'
--				when LogMessage like '{"error%' then 'Error'
--				when LogMessage like '{"type":"GRANT%' then 'Grant'
--				when LogMessage like '{"type":"REVOKE%' then 'Revoke'
--				else 'Unclassified' -- left(LogMessage, 32)
--			end,
--			LogMessage
--		from
--			dbo.atbl_AzureAdSync_Log with (nolock)
--	) T
--where
--	cast(Created as date) = cast(getdate() as date)
--	and datepart(hour, Created) = @runHour
--	and (
--		@topOfTheHour = 1
--		and datepart(minute, Created) < 30
--		or
--		@topOfTheHour = 0
--		and datepart(minute, Created) > 29
--	)
--order by
--	Created desc


/*
 * Flag a user in a run
 */
declare @runHour int = 14
declare @topOfTheHour bit = 0
declare @userMailPattern nvarchar(128) = '%your.email@here.foo%'
select
	PrimKey,
	Created,
	Flag = case when LogMessage like @userMailPattern then 'boop' else '' end,
	LogMessageClass,
	LogMessage
from
	(
		select
			PrimKey,
			Created,
			-- LogMessageSource = json_value(LogMessage, '$.source'),
			LogMessageClass = case
				when LogMessage like '{"runId"%' then 'Message'
				when  LogMessage like '{"@odata.context"%' then 'Data'
				when  LogMessage like '{"message": {"type": "RUN_START%' then 'StartFlag'
				when LogMessage like '{"error%' then 'Error'
				when LogMessage like '{"type":"GRANT%' then 'Grant'
				when LogMessage like '{"type":"REVOKE%' then 'Revoke'
				else 'Unclassified' -- left(LogMessage, 32)
			end,
			LogMessage
		from
			dbo.atbl_AzureAdSync_Log with (nolock)
	) T
where
	cast(Created as date) = cast(getdate() as date)
	and datepart(hour, Created) = @runHour
	and (
		@topOfTheHour = 1
		and datepart(minute, Created) < 30
		or
		@topOfTheHour = 0
		and datepart(minute, Created) > 29
	)
order by
	Created desc
