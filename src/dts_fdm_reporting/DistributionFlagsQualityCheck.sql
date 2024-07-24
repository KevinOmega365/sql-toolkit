declare @BatchRef uniqueidentifier = (
    select top 1 INTEGR_REC_BATCHREF
    from dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
    where INTEGR_REC_GROUPREF = '564d970e-8b1a-4a4a-913b-51e44d4bd8e7'
)
-- select @BatchRef

-------------------------------------------------------------------------------
select
    I.DCS_Domain,
    I.DCS_DocumentID,
    DtsFlagsSorted,
    FdmFlagsSorted
from
    dbo.ltbl_Import_DTS_DCS_Documents AS I WITH (NOLOCK)
    join (
        select
            FdmFlagsSorted = (
                select
                    '|' +
                    string_agg(cnctv.v, '|') within group (order by cnctv.v) +
                    '|'
                from
                    openjson(FDM.distributionflags_items, '$')
                        with (v nvarchar(max) '$.value') as cnctv
            ),
            DtsFlagsSorted =
                '|' +
                (
                    select
                        string_agg(json_value(value, '$.value'), '|')
                            within group (order by value)
                    from
                        openjson(DTS.otherCompanyDistributions)
                ) +
                '|',
            DTS.PrimKey,
            DTS.INTEGR_REC_BATCHREF

        from
            dbo.ltbl_Import_DTS_DCS_Documents DTS with (nolock)
            join dbo.ltbl_Import_ProArc_Documents FDM with (nolock)
                on FDM.facility_code = DTS.facilityCode -- facility code is mapped to DCS_Domain
                and FDM.document_number = DTS.DCS_DocumentID
                and FDM.INTEGR_REC_BATCHREF = DTS.INTEGR_REC_BATCHREF
    ) DistributionFlagsComparison
        on DistributionFlagsComparison.PrimKey = I.PrimKey
where
    isnull(FdmFlagsSorted, '') <> isnull(DtsFlagsSorted, '')
    and DistributionFlagsComparison.INTEGR_REC_BATCHREF = @BatchRef
    and I.INTEGR_REC_BATCHREF = @BatchRef
order by
    I.DCS_Domain,
    I.DCS_DocumentID
