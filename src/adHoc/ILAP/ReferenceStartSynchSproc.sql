CREATE OR ALTER PROCEDURE [dbo].[astp_AzureAdSync_StartSynch]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LogMessage NVARCHAR(MAX) = '{"message": {"type": "RUN_START", "title": "Start Azure AD Sync"}}'
	DECLARE
		@MailSender nvarchar(128) = 'af_noreply_DCS',
		@AdminEmail nvarchar(128) = 'you@yourdomain.com',
		@MailText nvarchar(max),
		@SmtpHost nvarchar(128) = (select [SmtpHost] from dbo.stbl_Database_Setup WITH (NOLOCK)) -- todo: check whether this have more than one row?

	---------------------------------------------------------------------------
	---------------------------------------------------------- Status Checks --
	---------------------------------------------------------------------------

	------------------------------------- Message admins if there are errors --

	IF EXISTS(
		SELECT *
		FROM dbo.atbl_AzureAdSync_Jobs WITH (NOLOCK)
		WHERE State = 'ERROR'
	) BEGIN

		-- Look at the previous start state from the log
		DECLARE @LastStart NVARChAR(MAX) = (
			SELECT TOP 1 LogMessage 
			FROM
				[dbo].[atbl_AzureAdSync_log] WITH (NOLOCK)
			WHERE
				JSON_VALUE(LogMessage, '$.message.type') = 'RUN_START'
			ORDER BY
				Created DESC
		)
		-- If the import fails twice in a row, stop trying and spam the admin
		IF(JSON_VALUE(@LastStart, '$.startState.startType') = 'restart')
		BEGIN
			SET @MailText = 'There is an error in AzureAdSync on ' + DB_NAME() + '. Please troubleshoot.'

			EXECUTE [dbo].[sstp_Mail_MessageSendImmediate] 
				@FromLogin = @MailSender
				,@ToEmail = @AdminEmail
				,@Subject = 'AzureAdSync Error'
				,@TextHTML = @MailText
				

			RETURN
		END
		ELSE -- If this is the 1st error, reset and warn the admin
		BEGIN
			DELETE [dbo].[atbl_AzureAdSync_Jobs] -- reset jobs

			SET @LogMessage = JSON_MODIFY(
				@LogMessage,
				'append $.startState',
				JSON_QUERY('{"type": "restart", "prevState": "ERROR"}')
			)

			SET @MailText = 'Restarting Azure AD Synch on ' + DB_NAME() + ' after encountering an error.'

			EXECUTE [dbo].[sstp_Mail_MessageSendImmediate] 
				@FromLogin = @MailSender
				,@ToEmail = @AdminEmail
				,@Subject = 'AzureAdSync Warning'
				,@TextHTML = @MailText
				
		END

	END

	--------------------------------- DON'T CREATE IF THERE ARE RUNNING JOBS --

	IF EXISTS(SELECT * FROM dbo.atbl_AzureAdSync_Jobs WITH (NOLOCK)) BEGIN -- if running
		IF EXISTS( -- longer than an hour
			SELECT *
			FROM [dbo].[atbl_AzureAdSync_Jobs] WITH (NOLOCK)
			WHERE Created < DATEADD(HOUR, -1, GETDATE())
		) BEGIN -- warn the admin

			SET @MailText = 'One or more jobs have been running for more than an hour on ' + DB_NAME() + '. Please troubleshoot.'

			EXECUTE [dbo].[sstp_Mail_MessageSendImmediate] 
				@FromLogin = @MailSender
				,@ToEmail = @AdminEmail
				,@Subject = 'AzureAdSync Warning'
				,@TextHTML = @MailText
			
		END

		RETURN
	END


	---------------------------------------------------------------------------
	----------------------------------------------------------- Housekeeping --
	---------------------------------------------------------------------------

	------------------------------------------------- Delete old log entries --

	DECLARE @daysToKeep INT = 3
	DELETE dbo.atbl_AzureAdSync_Log
	WHERE Created < CAST(DATEADD(DAY, - @daysToKeep, GETUTCDATE()) AS DATE)


	---------------------------------------------------------------------------
	----------------------------------------------------------- Run the Jobs --
	---------------------------------------------------------------------------

	----------------------------------------------- Empty the staging tables --

	DELETE dbo.atbl_AzureAdSync_Users_Staging
	DELETE dbo.atbl_AzureAdSync_UsersGroups_Staging

    ------------------------------------------------ Create a Job Collection --

	DECLARE @RunID UNIQUEIDENTIFIER = NEWID()

	INSERT INTO dbo.atbl_AzureAdSync_Jobs (
		[PrimKey],
		[Type],
		[Parent],
		[State]
	) VALUES (
		@RunID,
		'RunCollection',
		NULL,
		'Running'
	)

	INSERT INTO dbo.atbl_AzureAdSync_Jobs (
		[Type],
		[Parent],
		[State],
		[GroupPrimKey]
	)
	SELECT
		'JobRun',
		@RunID,
		'Running',
		PrimKey
	FROM
		dbo.atbl_AzureAdSync_Groups WITH (NOLOCK)

	---------------------------------------------------------- Log Run Start --

	-- if there's no other start state this is a normal start
	IF(JSON_VALUE(@LogMessage, '$.startState') IS NULL)
	BEGIN
		SET @LogMessage = JSON_MODIFY(
			@LogMessage,
			'append $.startState',
			JSON_QUERY('{"type": "normal"}')
		)
	END
	EXECUTE dbo.astp_AzureAdSync_WriteLog @LogMessage

    ------------------------ Add queue table entries for the JobRun children --

	DECLARE @UserBatchSize NVARCHAR(3) = '25'

	INSERT INTO dbo.atbl_AzureAdSync_Queue (
		[GroupPrimKey],
		[URL],
		[Token],
		[RunID],
		[JobID]
	)
	SELECT
		Groups.PrimKey,
		URL = 'https://graph.microsoft.com/v1.0/'
			+ 'groups/' + CAST(Groups.AzureID AS NVARCHAR(MAX)) + '/members'
			+ '?'
				+ '$top=' + @UserBatchSize
				+'&'
				+ '$select='
					+ 'id' + '%2c'
					+ 'businessPhones' + '%2c'
					+ 'displayName' + '%2c'
					+ 'givenName' + '%2c'
					+ 'jobTitle' + '%2c'
					+ 'mail' + '%2c'
					+ 'otherMails' + '%2c'
					+ 'mobilePhone' + '%2c'
					+ 'officeLocation' + '%2c'
					+ 'preferredLanguage' + '%2c'
					+ 'surname' + '%2c'
					+ 'userPrincipalName' + '%2c'
					+ 'accountEnabled' + '%2c'
					+ 'userType' + '%2c'
					+ 'companyName',
		Token = NULL,
		Jobs.Parent,
		Jobs.PrimKey
	FROM
		dbo.atbl_AzureAdSync_Jobs AS Jobs WITH (NOLOCK)
		JOIN dbo.atbl_AzureAdSync_Groups AS Groups WITH (NOLOCK)
			ON Groups.PrimKey = Jobs.GroupPrimKey
	WHERE
		Jobs.Parent = @RunID
		
END
