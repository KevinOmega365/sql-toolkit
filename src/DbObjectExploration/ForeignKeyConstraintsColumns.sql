
/*
 * find constraints on a column for a table
 */
select
    [ID],
    [TableName],
    [ConstraintSuffix],
    [ForeignColumnName], 
    [PrimaryColumnName],
    [PrimaryKeyTable],
    [ConstraintColumnID],
    [IndexName]
from
    dbo.stbl_DbTools_ForeignKeyConstraintsColumns with (nolock)
where
    TableName  = 'atbl_DCS_Documents'
    And IndexName = 'FK_atbl_DCS_Documents_atbl_Asset_CompanyCodes_Originator'

/*
 * find constraints on a column for a table
 */
-- select
--     [ID],
--     [TableName],
--     [ConstraintSuffix],
--     [ForeignColumnName], 
--     [PrimaryColumnName],
--     [PrimaryKeyTable],
--     [ConstraintColumnID],
--     [IndexName]
-- from
--     dbo.stbl_DbTools_ForeignKeyConstraintsColumns with (nolock)
-- where
--     TableName  = 'atbl_DCS_Documents'
--     And ForeignColumnName = 'OriginatorCompany'

/**
 * foreign keys and related tables
 */
-- select
--     PrimaryKeyTable,
--     ConstraintName
-- from
--     dbo.stbl_DbTools_ForeignKeyConstraintsColumns with (nolock)
-- where
--     TableName  = 'atbl_DCS_Documents'
-- group by
--     PrimaryKeyTable,
--     ConstraintName

/**
 * sample
 */
-- select top 10 *
-- from dbo.stbl_DbTools_ForeignKeyConstraintsColumns with (nolock)
-- where TableName  = 'atbl_DCS_Documents'
-- order by newid()