declare @start datetime = getdate()
waitfor delay '00:00:01'
print datediff(millisecond, @start, getdate())
