/*
 * Null and equality
 */
select
    [W] = 'LHS = RHS',
    [A] = 'A',
    [T] = 'B',
    [!] = 'Null'
union all
select
    [W] = 'A',
    [A] = case when 'A' = 'A'  then 'yupp' else 'nope' end,
    [T] = case when 'A' = 'B'  then 'yupp' else 'nope' end,
    [!] = case when 'A' = NULL then 'yupp' else 'nope' end
union all
select
    [W] = 'B',
    [A] = case when 'B' = 'A'  then 'yupp' else 'nope' end,
    [T] = case when 'B' = 'B'  then 'yupp' else 'nope' end,
    [!] = case when 'B' = NULL then 'yupp' else 'nope' end
union all
select
    [W] = 'NULL',
    [A] = case when NULL = 'A'  then 'yupp' else 'nope' end,
    [T] = case when NULL = 'B'  then 'yupp' else 'nope' end,
    [!] = case when NULL = NULL then 'yupp' else 'nope' end

/*
 * Null and inequality
 */
select
    [W] = 'LHS <> RHS',
    [A] = 'A',
    [T] = 'B',
    [!] = 'Null'
union all
select
    [W] = 'A',
    [A] = case when 'A' <> 'A'  then 'yupp' else 'nope' end,
    [T] = case when 'A' <> 'B'  then 'yupp' else 'nope' end,
    [!] = case when 'A' <> NULL then 'yupp' else 'nope' end
union all
select
    [W] = 'B',
    [A] = case when 'B' <> 'A'  then 'yupp' else 'nope' end,
    [T] = case when 'B' <> 'B'  then 'yupp' else 'nope' end,
    [!] = case when 'B' <> NULL then 'yupp' else 'nope' end
union all
select
    [W] = 'NULL',
    [A] = case when NULL <> 'A'  then 'yupp' else 'nope' end,
    [T] = case when NULL <> 'B'  then 'yupp' else 'nope' end,
    [!] = case when NULL <> NULL then 'yupp' else 'nope' end
