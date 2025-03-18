CREATE OR ALTER FUNCTION [dbo].[afnc_Integrations_GetSequenceOrder] (
    @SortOrder INT
) RETURNS NVARCHAR(15)
AS
BEGIN

    DECLARE @result VARCHAR(50) = ''
    DECLARE @segment INT

    WHILE @SortOrder > 0
    BEGIN
        SET @segment = @SortOrder % 100

        IF(@result <> '' OR @segment <> 0)
        BEGIN
            SET @result = CAST(@segment AS VARCHAR) + '.' + @result
        END
        
        SET @SortOrder = @SortOrder / 100
    END

    RETURN LEFT(@result, LEN(@result) - 1) -- remove the trailing dot

END
