
declare @crlf char(2) = CHAR(13)+CHAR(10)
declare @tab char(4) = '    '

declare
    @Param0 nvarchar(64) = N'Regular',
    @Param1 nvarchar(3) = N'145',
    @Param2 nvarchar(3) = N'153',
    @Param3 nvarchar(50) = N'%fail%'

declare
    @fromDomain nvarchar(128),
    @toDomain nvarchar(128),
    @errorMessage nvarchar(max),
    @sql nvarchar(max) = ''

set @errorMessage = 'Cannot insert duplicate key row in object ''dbo.atbl_DCS_RevisionsFiles'' with unique index ''UI_atbl_DCS_RevisionsFiles_UniqueFileName''. The duplicate key value is (099, PWP-AK-E-02030-001, 1, Original, PWP-AK-E-02030-001_01_C-IFI-I_2025-02-21_01.PDF).	'

-----------------------------------------------------------------------------

-- SELECT
--     @fromDomain = [FromDomain],
--     @toDomain = [ToDomain],
--     @errorMessage = [ErrorMessage]
-- FROM
--     [dbo].[aviw_DCS_MirrorDomains]
-- WHERE
--     [RecordStatus] = @Param0
--     AND [FromDomain] IN (@Param1, @Param2)
--     AND [Status] LIKE @Param3
-- ORDER BY
--     [FromDomain]

-----------------------------------------------------------------------------

declare @RevisionFileKeys table
(
	id int,
    [key] nvarchar(128)--,
	-- value nvarchar(max)
)
insert into @RevisionFileKeys (id, [key])
values
    (1, 'Domain'),
    (2, 'DocumentID'),
    (3, 'RevisionItemNo'),
    (4, 'Type'),
    (5, 'Filename')

-- select * from @RevisionFileKeys

-------------------------------------------------------------------------------

-- todo: going to need some #tempTable for this...

select
    -- activate_link_document =
    --     '<a href="' +
    --     'https://pims.akerbp.com/dcs-documents-details?Domain=' +
    --     Domain +
    --     '&DocID=' +
    --     DocumentID +
    --     '">' +
    --     DocumentID +
    --     '</a>',
    DeleteRevisionFile = 'select * from dbo.atbl_DCS_RevisionsFiles with (nolock) where ' + string_agg([key] + ' = ''' + value + '''', ' and ')
from
(
    select
        [key],
        value
    from
        @RevisionFileKeys IdsKeys
        join (
            select
                Id,
                value = entry
            from
                [dbo].[sfnc_System_String_Split] (
                    substring (
                        @errorMessage,
                        charindex('(', @errorMessage) + 1,
                        charindex(')', @errorMessage) - charindex('(', @errorMessage) - 1
                    )
                    , ', '
                )
        ) IdsValues
            on IdsValues.Id = IdsKeys.id
) KeyValues

-- select count(*)
-- from dbo.atbl_DCS_RevisionsFiles with (nolock)
-- where


-- print 'Fix Mirror Domain from transfer ' +  @fromDomain + ' to ' + @toDomain

-- set @sql = @sql + 'select * from dbo.atbl_DCS_RevsisionsFiles with (nolock) where '

-- print @sql



/*
execute dbo.astp_DCS_MirrorDocuments
    @FromDomainFilter = '187',
    @FromContractFilter = null,
    @SkipNotification = 1
*/
