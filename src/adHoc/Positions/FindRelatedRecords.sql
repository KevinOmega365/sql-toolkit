/*
 * Collect counts all of the related records for a position
 *
 * The goal would be to automagically re-wire or delete
 * So that we can delete the Positions and run date updated
 */

-- declare @ProcedureCall nvarchar(512) = 'sp_fkeys ''' + @tableName + ''''
-- EXEC sys.sp_describe_first_result_set @ProcedureCall

declare @tableName nvarchar(128) = 'atbl_Positions_Positions'
declare @PositionUser nvarchar(128) = 'bob.dobbs@churchofthesubgenius.org'


declare @PersonPositionID int = 40497

drop table if exists #ReferencingEntities
create table #ReferencingEntities (
    PKTABLE_QUALIFIER nvarchar(128),
    PKTABLE_OWNER nvarchar(128),
    PKTABLE_NAME nvarchar(128),
    PKCOLUMN_NAME nvarchar(128),
    FKTABLE_QUALIFIER nvarchar(128),
    FKTABLE_OWNER nvarchar(128),
    FKTABLE_NAME nvarchar(128),
    FKCOLUMN_NAME nvarchar(128),
    KEY_SEQ smallint,
    UPDATE_RULE smallint,
    DELETE_RULE smallint,
    FK_NAME nvarchar(128),
    PK_NAME nvarchar(128),
    DEFERRABILITY smallint
)

insert into #ReferencingEntities
exec sp_fkeys @tableName

select
    SqlSubselect = 'select PersonPositionId = ' + cast(@PersonPositionId as nvarchar(8)) + ', TableName = ''' + FKTABLE_NAME + ''', Count = (select count(*) from dbo.' + FKTABLE_NAME + ' as F with (nolock) where F.' + FKCOLUMN_NAME + ' = ' + cast(@PersonPositionId as nvarchar(8)) + ') union all '
    -- , PKTABLE_NAME
    -- , PKCOLUMN_NAME
    -- , FKTABLE_NAME
    -- , FKCOLUMN_NAME
from
    #ReferencingEntities
