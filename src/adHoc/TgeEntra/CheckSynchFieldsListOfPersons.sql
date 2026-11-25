declare @updated_users nvarchar(max) = '[
    {
        "PrimKey": "c7121daf-2732-40cc-a2fb-4c415e611e0d"
    },
    {
        "PrimKey": "e9d021a5-3c9f-4ac7-90a0-2ccd08eb35f7"
    },
    {
        "PrimKey": "7bf24a5f-d831-477d-8183-aca2eb5d6195"
    }
]'

select top 100 percent
    P.Email,
    PU.External_ID,
    P.ADAccount,
    P.CurrentPosition,
    ReportsTo_ID,
    UserCostCode_ID,
    Branch = SystemPerson_Branch.Value,
    Initial = SystemPerson_Initial.Value,
    WeeklyWH = SystemPersons_WeeklyWH.Value
from
    dbo.stbl_System_Persons as P
    join (
        select PrimKey
        from
            openjson(@updated_users) with (
                PrimKey uniqueidentifier '$.PrimKey'
            )
    ) as U
        on U.PrimKey = P.PrimKey
    -- start properties
    left join dbo.stbl_System_PersonsProperties as SystemPerson_Branch
        on SystemPerson_Branch.Person_ID = P.ID
        and SystemPerson_Branch.PropertyName = 'SystemPerson_Branch'
    left join dbo.stbl_System_PersonsProperties as SystemPerson_Initial
        on SystemPerson_Initial.Person_ID = P.ID
        and SystemPerson_Initial.PropertyName = 'SystemPerson_Initial'
    left join dbo.stbl_System_PersonsProperties as SystemPersons_WeeklyWH
        on SystemPersons_WeeklyWH.Person_ID = P.ID
        and SystemPersons_WeeklyWH.PropertyName = 'SystemPersons_WeeklyWH'
    -- end properties
    left join dbo.stbl_System_PersonsUsers as PU
        on PU.Person_ID = P.ID
        and PU.External_ID = P.ADAccount
order by
    P.Email
