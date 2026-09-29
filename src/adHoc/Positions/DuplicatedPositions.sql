/*
 * Person { PersonID, Login }, Postion { Domain, Name, PostionType } RowNum as duplication factor, Per position person count
 */
select
    PersonDetails.Login,
    PersonDetails.PersonID,
    DomainDetails.Domain,
    Position = PositionDetails.Name,
    PositionType = PositionTypeDetails.Title,
    PositionDetails.CreatedBy,
    Duplication = row_number() over (
        partition by
            PersonDetails.Login,
            PersonDetails.PersonID,
            DomainDetails.Domain,
            PositionDetails.Name,
            PositionTypeDetails.Title
        order by
            PositionDetails.Created
    ),
    PersonCount = (
        select count(*)
        from dbo.atbl_Positions_PositionsPersons as PP with (nolock)
        where PP.Position_ID = IntegrationRelatedPersonPositions.Position_ID
    )
from
    (
    select -- 1386
        PersonID, Position_ID
    from
        dbo.atbl_Positions_PositionsPersons as PosPers with (nolock)
    where
        exists (
            select *
            from
                dbo.atbl_Positions_Positions as ImportedPos with (nolock)
                join dbo.atbl_Positions_PositionsPersons as ImportedPosPers with (nolock)
                    on ImportedPosPers.Position_ID = ImportedPos.ID
            where
                ImportedPosPers.PersonID = PosPers.PersonID
                and ImportedPos.CreatedBy = 'af_Integrations_ServiceUser'
        )
    ) as IntegrationRelatedPersonPositions
    join dbo.atbl_ProjectSetup_Persons as PersonDetails with (nolock)
        on PersonDetails.PersonID = IntegrationRelatedPersonPositions.PersonID
    join dbo.atbl_Positions_Positions as PositionDetails with (nolock)
        on PositionDetails.ID = IntegrationRelatedPersonPositions.Position_ID
    left join dbo.atbl_Positions_PositionTypes as PositionTypeDetails with (nolock)
        on PositionTypeDetails.ID = PositionDetails.PositionTypeID
    join dbo.stbl_System_Domains as DomainDetails with (nolock)
        on DomainDetails.ID = PositionDetails.Domain_ID
order by
    PersonDetails.Login,
    PersonDetails.PersonID,
    DomainDetails.Domain,
    PositionDetails.Name,
    PositionTypeDetails.Title,
    Duplication

/*
 * Person-Positions per person with at least one position created by af_Integrations_ServiceUser
 */
-- select
--     count(*)
-- from
--     dbo.atbl_Positions_PositionsPersons as PosPers with (nolock)
-- where
--     exists (
--         select *
--         from
--             dbo.atbl_Positions_Positions as ImportedPos with (nolock)
--             join dbo.atbl_Positions_PositionsPersons as ImportedPosPers with (nolock)
--                 on ImportedPosPers.Position_ID = ImportedPos.ID
--         where
--             ImportedPosPers.PersonID = PosPers.PersonID
--             and ImportedPos.CreatedBy = 'af_Integrations_ServiceUser'
--     )

/*
 * how many person-position links have we made
 */
-- select count(*)
-- from dbo.atbl_Positions_PositionsPersons as PosPers with (nolock)
-- where PosPers.CreatedBy = 'af_Integrations_ServiceUser'

/*
 * We want to clean out - all of the positions with
 *   - a single person
 *   - duplicate entries
 *     - Domain
 *     - Name
 *     - PostionType
 *     - Person
 *
 * - we may need to migrate|merge|delete related records
 *
 * - we may not have created all of the persons
 * - we may not have created all of the positions
 */
