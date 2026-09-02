
declare
    @PosID int = 41309,
    @Inactive bit = 0

SELECT
[PrimKey],
[Position_ID],
[PersonID],
[FromDate],
[ToDate],
[PersonName],
[FirstNameLastName],
[EMailAddress],
[Inactive],
[Login],
[MissingLogin],
[CompanyName],
[PersonExpired],
[UserExpired],
[PersonRole_ID],
[PersonRole],
[PersonRoleDescription]
FROM
    [dbo].[aviw_Positions_PositionsPersons]
WHERE
    (
        [Position_ID] = @PosID
        AND [Inactive] = @Inactive -- this is what disappears the records in the UI
    )
ORDER BY [PersonName]


select count(*) 
from
    dbo.atbl_Positions_Positions AS Pos WITH (NOLOCK)
    left join dbo.atbl_Positions_PositionsPersons PosPers WITH (NOLOCK)
        ON PosPers.Position_ID = Pos.ID
where
    Pos.CreatedBy = 'af_Integrations_ServiceUser'
    and Pos.ID = @PosID
