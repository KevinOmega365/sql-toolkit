
declare
    @domainContractDelimiter nchar(3) = ' - ',
    @domainContractListDelimiter nchar(1) = ';',
    @validationJsonBase nvarchar(max) = '{"validation": []}'

declare @domainContractListDelimiterPlusSpace nchar(2) = @domainContractListDelimiter + ' '

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


declare @InputData table (
    Domain nvarchar(max),
    -- ProjectNumber nvarchar(max),
    -- DCS_DocumentID nvarchar(max),
    ExistingInterfaceContractList nvarchar(max),
    ImportInterfaceContractList nvarchar(max),
    Trace nvarchar(max),
    PrimKey uniqueidentifier
)
insert into @InputData
values
    (
        '158',
        '145 - C-01989; 155 - FA-00518-144',
        '145 - C-01989; 256 - S0-WH4T; 155 - FA-00518-144; 099 - C-01421; balder - F-00-B4R',
        null,
        newid()
    )
    -- todo: make some more test data

--------------------------------------------------------------------------------
-- split domain-contract lists
--------------------------------------------------------------------------------


declare @ValidationTable table (
    Domain nvarchar(128),
    ContractDomain nvarchar(128),
    ContractNo nvarchar(50),
    DomainContract nvarchar(max),
    Validated bit,
    PrimKey uniqueidentifier
)


insert into @ValidationTable
select
    Domain,
    ContractDomain =
        left(
            DomainContract,
            charindex(@domainContractDelimiter, DomainContract) - 1
        ),
    ContractNo =
        right(
            DomainContract,
            len(DomainContract) - (
                charindex(@domainContractDelimiter, DomainContract) +
                len(@domainContractDelimiter)
            )
        ),
    DomainContract,
    Validated = 1,
    PrimKey
from
        (
            select
                Domain,
                DomainContract = trim(value),
                PrimKey
            from
                @InputData ImportedContractDomainValues
                cross apply string_split
                (
                    ImportInterfaceContractList,
                    @domainContractListDelimiter
                )
                AS DomainContractList

        union -- remove duplicates between existing and imported

            select
                Domain,
                DomainContract = trim(value),
                PrimKey
            from
                @InputData ExistingContractDomainValues
                cross apply string_split
                (
                    ExistingInterfaceContractList,
                    @domainContractListDelimiter
                )
                AS DomainContractList
    ) T


--------------------------------------------------------------------------------
-- do validation
--------------------------------------------------------------------------------

/**
 * Do validation
 */
update CandidateData
    set Validated = 0
from
    @ValidationTable CandidateData
    left join dbo.atbl_DCS_InterfaceMgmt_Interfaces as Interfaces with (nolock)
        on CandidateData.Domain = Interfaces.Domain
        and CandidateData.ContractDomain = Interfaces.SourceDomain
        and CandidateData.ContractNo = Interfaces.SourceContractNo
where
    Interfaces.PrimKey is null

/**
 * Validation trace
 */
update I
set
    Trace = JSON_MODIFY(
        isnull(nullif(Trace, ''), @validationJsonBase),
        '$.validation', -- overwrites validation array
        json_query(V.TraceMessagesJsonArray) -- interpret as JSON rather than string
    )
from
    @InputData I
    join (
        select
            PrimKey,
            -- todo: try as for json selection
            TraceMessagesJsonArray = '["' + 
            string_agg(
                'Domain-Contract (' +
                DomainContract +
                ') not found for Domain (' +
                Domain +
                ')'
                ,
                '","'
            ) +
        '"]'
        from
            @ValidationTable
        where
            Validated = 0
        group by
            PrimKey
    ) V
        on V.PrimKey = I.PrimKey

--------------------------------------------------------------------------------
-- reassemble
--------------------------------------------------------------------------------

select
    InputData.Domain,
    InputData.ExistingInterfaceContractList,
    InputData.ImportInterfaceContractList,
    MergedList = string_agg(
        DomainContract,
        @domainContractListDelimiterPlusSpace
        ),
    -- Validated = cast(min(T.Validated) as bit), -- choice A: invalidate here
    Trace,
    CheckTraceJson = isjson(Trace),
    InputData.PrimKey
from
    (
        select
            Domain
            ContractDomain,
            ContractNo,
            DomainContract,
            Validated = cast(Validated as int),
            PrimKey
        from
            @ValidationTable ValidatedContractDomains
        where
            Validated = 1 -- exclude invalid values -- choice B: only take valid domain-contracts
    ) T
        join @InputData InputData
            on InputData.Primkey = T.Primkey
group by
    InputData.Domain,
    InputData.ExistingInterfaceContractList,
    InputData.ImportInterfaceContractList,
    InputData.Trace,
    InputData.PrimKey

--------------------------------------------------------------------------------
-- notes
--------------------------------------------------------------------------------

select * from @ValidationTable