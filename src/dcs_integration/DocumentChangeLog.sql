
declare @Domain nvarchar(128) = N'128'
declare @DocumentID nvarchar(100) = N'FPQ-ER328-LA-00004' -- 'FPQ-ER328-MA-00001' -- 'FPQ-ER328-KA-00002'
declare @FieldName nvarchar(128) = '%'

SELECT
    [Source],
    [Created],
    [CreatedBy],
    [FieldName],
    [FieldValue],
    [OldValue],
    [Comments]
FROM
    [dbo].[aviw_DCS_DocumentsLogCrossDomain]
WHERE
    (
        [Domain] = @Domain
        AND [DocumentID] = @DocumentID
        AND [FieldName] like @FieldName
    )
ORDER BY
    [Created] DESC
