/*
 * Duplicated users with row nubmer on created
 */
select
    ID,
    FirstName,
    LastName,
    Email,
    RowNum = row_number() over (partition by FirstName, LastName, Email order by Created),
    Created
from
    dbo.stbl_System_Persons P
where
    exists (
        select FirstName,LastName,Email
        from dbo.stbl_System_Persons Duplicates
        where
            Duplicates.FirstName = P.FirstName
            and Duplicates.LastName = P.LastName
            and Duplicates.Email = P.Email
        group by
            FirstName,
            LastName,
            Email
        having
            count(*) > 1
    )

-- select FirstName,LastName,Email from dbo.stbl_System_Persons group by FirstName,LastName,Email having count(*) > 1
