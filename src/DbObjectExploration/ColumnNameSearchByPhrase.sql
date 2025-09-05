/*
 * look for a good column name match from a user's phrase
 */
declare
    @tableName nvarchar(128) = 'atbl_DCS_Revisions',
    @searchPhrase nvarchar(256) = 'Contractor Supplier Acceptance Code'

select
    ColumnName = name,
    MatchingTerms = string_agg(SearchTerms.value, ', ')
from
    sys.columns ColumnNames
    join string_split(@searchPhrase, ' ') SearchTerms
        on ColumnNames.name like '%' + SearchTerms.value + '%'
where
    object_id = object_id(@tableName)
group by
    ColumnNames.name
order by
    count(*) desc,
    MatchingTerms,
    ColumnName
