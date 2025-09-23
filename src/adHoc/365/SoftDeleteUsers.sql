
declare @DeletionDateTime datetime2 = SYSDATETIME()

Update P
set
    -- P.Email = 'xxx' + P.Email + 'xxx',
    -- P.ADAccount = 'xxx' + P.ADAccount + 'xxx',
    P.Deleted = @DeletionDateTime
from
    dbo.stbl_System_Persons P
    join dbo.stbl_System_PersonsUsers PU
        on PU.Person_ID = P.ID
where
    P.Comment like 'Imported FROM Azure AD:%'

    -- and P.Email like 'xxx%xxx'
    -- and P.ADAccount like 'xxx%xxx'

    -- and exists (
    --     select
    --         D.FirstName,
    --         D.LastName,
    --         D.Email
    --     from
    --         dbo.stbl_System_Persons D -- Duplicates
    --     where
    --         D.FirstName = P.FirstName
    --         and D.LastName = P.LastName
    --         and D.Email = P.Email
    --     group by
    --         D.FirstName,
    --         D.LastName,
    --         D.Email
    --     having
    --         count(*) > 1
    -- )
