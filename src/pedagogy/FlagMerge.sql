/*
 *  Given
 *      a set of distribution input (key) values K: K1 .. Kn
 *      a corresponding set of output values V: V1 .. Vn
 *      a set of other values O: O1 .. On
 *
 *      overwrite V with V* keep O
 *      V  : current Pims Flags
 *      K  : insomming Keys
 *      V* : incomming Flags (K => V*)
 *      AV : All possible V from mapping table
 *      O  : V - AV
 *
 *      DCS_Flags <= O + V*
 */

declare @PimsFlags nvarchar(max) = 'O1; V1; V3' -- some random row

declare @InputJson nvarchar(max) = '[{"value":"K2"}]' -- '[]' -- '[{"value":"K1"},{"value":"K2"}]'

/* hard coded */
declare @MappingTable table (
    DistKey nvarchar(max),
    FlagValue nvarchar(max)
)
insert into @MappingTable
values
('K1', 'V1'),
('K2', 'V2'),
('K3', 'V3')

declare @AllValues nvarchar(max) = (
    select string_agg(FlagValue, '; ')
    from @MappingTable
)

declare @LocalFlags nvarchar(max) = (
    select string_agg(Flag, '; ')
    from (
        select Flag = trim(value) from string_split(@PimsFlags, ';')
        except
        select Flag = trim(value) from string_split(@AllValues, ';')
    ) T
)

declare @IncomingFlags nvarchar(max) = (
    select string_agg(FlagValue, '; ')
    from (
        select FlagValue
        from 
            openjson(@InputJson)
            join @MappingTable
                on json_value(value, '$.value') LIKE DistKey
    ) T
)

declare @NewFlag nvarchar(max) = (
    select string_agg(Flag, '; ') within group (order by Flag)
    from (
        select Flag = trim(value) from string_split(@LocalFlags, ';')
        union
        select Flag = trim(value) from string_split(@IncomingFlags, ';')
    ) T
)

/*
 * Because I'm a bag person
 */
select
    PimsFlags = @PimsFlags,
    InputJson = @InputJson,
    AllValues = @AllValues,
    LocalFlags = @LocalFlags,
    IncomingFlags = @IncomingFlags,
    NewFlag = @NewFlag,
    OnTheFly = (
        select
            string_agg(Flag, '; ') within group (order by Flag)
        from
            (
                    select
                        Flag
                    from
                        (
                                select
                                    Flag = trim(value)
                                from
                                    string_split (@PimsFlags, ';') -- atbl_DCS_Documents.Flag"

                            except

                                select
                                    Flag = trim(value)
                                from
                                    string_split (@AllValues, ';')

                        ) FlagValuesFromPimsNotDefinedInImportMapping
        
                union
    
                    select
                        FlagValue
                    from
                        (
                            select
                                FlagValue
                            from
                                openjson (@InputJson) -- ltbl_Import_DTS_DCS_Documents.otherCompanyDistributions
                                join @MappingTable on json_value(value, '$.value') LIKE DistKey

                        ) ImportedDistributionFlags
    
            ) U
    )
