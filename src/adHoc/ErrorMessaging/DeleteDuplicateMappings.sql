delete from dbo.atbl_Integrations_Configurations_ErrorMappings
where
    PrimKey in (
        select
            PrimKey
        from
            (
                select
                    InstanceNumber =
                        row_number() over (
                            partition by
                                GroupRef,
                                OldErrorDescription,
                                NewErrorDescription,
                                MatchingPriority
                            order by
                                PrimKey
                        ),
                    GroupRef,
                    OldErrorDescription,
                    NewErrorDescription,
                    MatchingPriority,
                    PrimKey
                from
                    dbo.atbl_Integrations_Configurations_ErrorMappings with (nolock)
            ) T
        where
            InstanceNumber > 1
    )
