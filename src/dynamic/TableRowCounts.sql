
declare @tableListJson nvarchar(max) = '[
        "ltbl_Import_SharePointList_RolesListItems_RAW",
        "ltbl_Import_SharePointList_RolesListItems_STAGING",
        "ltbl_Import_SharePointList_ProjectsListItems_RAW",
        "ltbl_Import_SharePointList_ProjectsListItems_STAGING",
        "ltbl_Import_SharePointList_OnboardingListItems_RAW",
        "ltbl_Import_SharePointList_OnboardingListItems_STAGING"
    ]',
    @UnionAll nchar(11) = ' union all ',
    @SqlStatement nvarchar(max)

select
  @SqlStatement = string_agg(TableCountSql, @UnionAll)
from
  (
    select
      TableCountSql = 'select TableName = ''' + TableName + ''', Count = (select count(*) from dbo.' + TableName + ' with (nolock))'
    from
      (
        select
          TableName = value
        from
          openjson (@tableListJson)
      ) T
  ) U

exec sp_executesql @SqlStatement
