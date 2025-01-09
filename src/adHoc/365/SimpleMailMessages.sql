/*
 * Check the mailn sending settings
 */
-- SELECT S.DisableSMSAndEmailSending
-- FROM dbo.stbl_Database_Setup AS S

/*
 * Force send a message
 */
-- insert into dbo.stbl_Mail_SimpleMessages(
--     ForceSending,
--     FromEmail,
--     FromName,
--     ToEmail,
--     ToName,
--     Subject,
--     TextHTML
-- )
-- SELECT
--     ForceSending = 1,
--     FromMail = 'no-reply@omega365.com',
--     FromName = 'Omega 365 TGE',
--     ToEmail = 'kevin@omega365.com',
--     ToName = 'Kevin Francis',
--     Subject = 'Test email',
--     Body =
-- 'Hi Kevin,
-- <br>
-- <br>
-- There is no action required. This is a test.
-- <br>
-- <br>
-- Have a nice day!
-- <br>
-- <br>
-- Mvh
-- <br>
-- &nbsp;&nbsp;&nbsp;&nbsp;Pims
-- '

/*
 * Peek at the mail queue
 */
select top 50 * from dbo.stbl_Mail_SimpleMessages order by Created desc
