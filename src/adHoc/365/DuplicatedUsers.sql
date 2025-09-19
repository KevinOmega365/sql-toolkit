/*
 * Duplicated users with row number, id and ADAccount
 */
select
    P.ID,
    P.FirstName,
    P.LastName,
    P.Email,
    RowNum = row_number() over (
        partition by
            P.FirstName,
            P.LastName,
            P.Email
        order by
            P.Created),
    P.Created,
    P.ADAccount
into
    #DuplicatedPersons
from
    dbo.stbl_System_Persons P
    join dbo.stbl_System_PersonsUsers PU
        on PU.Person_ID = P.ID
where
    exists (
        select
            D.FirstName,
            D.LastName,
            D.Email
        from
            dbo.stbl_System_Persons D -- Duplicates
        where
            D.FirstName = P.FirstName
            and D.LastName = P.LastName
            and D.Email = P.Email
        group by
            D.FirstName,
            D.LastName,
            D.Email
        having
            count(*) > 1
    )

select * from #DuplicatedPersons



/*
 * Find duplicates
 */
-- select
--     Count = count(*),
--     FirstName,
--     LastName,
--     Email
-- from
--     dbo.stbl_System_Persons
-- group by
--     FirstName,
--     LastName,
--     Email
-- having
--     count(*) > 1
-- order by
--     Count desc,
--     FirstName,
--     LastName,
--     Email
