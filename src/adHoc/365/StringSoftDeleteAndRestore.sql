
-- "delete" an entry by wrapping a key value in 'x's
--- then restore it

DECLARE @InitialString nvarchar(max) = 'kevin@omega365.com'

DECLARE @DeletedString nvarchar(max) = 'xxx' + @InitialString + 'xxx'

DECLARE @RestoredString nvarchar(max) = substring(@DeletedString, 4, len(@DeletedString) - 6)

/*
 * Show the input and output
 */
select
    InitialString = @InitialString,
    DeletedString = @DeletedString,
    RestoredString = @RestoredString
