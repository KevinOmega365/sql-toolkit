/* 
 * Set Operators
 */

declare @A nvarchar(max) = 'V1; V3'
declare @B nvarchar(max) = 'V1; V2'

select
    A = @A,
    B = @B,
    A_intersect_B = (
        select string_agg(Flag, '; ')
        from (
            select Flag = trim(value) from string_split(@A, ';')
            intersect
            select Flag = trim(value) from string_split(@B, ';')
        ) T
    ),
    A_except_B = (
        select string_agg(Flag, '; ')
        from (
            select Flag = trim(value) from string_split(@A, ';')
            except
            select Flag = trim(value) from string_split(@B, ';')
        ) T
    ),
    A_union_B = (
        select string_agg(Flag, '; ')
        from (
            select Flag = trim(value) from string_split(@A, ';')
            union
            select Flag = trim(value) from string_split(@B, ';')
        ) T
    )
