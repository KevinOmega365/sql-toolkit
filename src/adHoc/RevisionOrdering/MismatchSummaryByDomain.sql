
select
    Domain,
    Dts_Pims_Mismatch,
    Dts_Max_Mismatch,
    Max_Pims_Mismatch,
    Count = count(*),
    Description =
        case
            when Dts_Pims_Mismatch = 0 and  Dts_Max_Mismatch = 0 and  Max_Pims_Mismatch = 0 then 'ok (everything matches)'
            when Dts_Pims_Mismatch = 1 and  Dts_Max_Mismatch = 0 and  Max_Pims_Mismatch = 0 then 'This cannot happen'
            when Dts_Pims_Mismatch = 0 and  Dts_Max_Mismatch = 1 and  Max_Pims_Mismatch = 0 then 'This cannot happen'
            when Dts_Pims_Mismatch = 1 and  Dts_Max_Mismatch = 1 and  Max_Pims_Mismatch = 0 then 'pims current and max match, but dts has a different current'
            when Dts_Pims_Mismatch = 0 and  Dts_Max_Mismatch = 0 and  Max_Pims_Mismatch = 1 then 'This cannot happen'
            when Dts_Pims_Mismatch = 1 and  Dts_Max_Mismatch = 0 and  Max_Pims_Mismatch = 1 then 'dts current matches the maximal revision, but pims current does not'
            when Dts_Pims_Mismatch = 0 and  Dts_Max_Mismatch = 1 and  Max_Pims_Mismatch = 1 then 'pims and dts current match, but it is not he maximal revision'
            when Dts_Pims_Mismatch = 1 and  Dts_Max_Mismatch = 1 and  Max_Pims_Mismatch = 1 then 'nothing matches'
        end
from
(
    select
        Domain,
        Dts_Pims_Mismatch =
            case
                when isnull(DtsCurrentRevision, '') <> isnull(PimsCurrentRevision, '')
                then 1
                else 0
            end,
        Dts_Max_Mismatch =
            case
                when isnull(DtsCurrentRevision, '') <> isnull(MaxRevision, '')
                then 1
                else 0
            end,
        Max_Pims_Mismatch =
            case
                when isnull(MaxRevision, '') <> isnull(PimsCurrentRevision, '')
                then 1
                else 0
            end,
        Total = 1
    from
        (
            select
                Domain,
                DocumentID,
                DtsCurrentRevision,
                PimsCurrentRevision,
                MaxRevision = max(Revision)
            from
                (
                    select
                        P.Domain,
                        P.DocumentID,
                        DtsCurrentRevision = I.currentRevision,
                        PimsCurrentRevision = P.CurrentRevision,
                        R.Revision
                    from
                        dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
                        join dbo.atbl_DCS_Documents P with (nolock)
                            on P.Domain = I.DCS_Domain
                            and P.DocumentID = I.DCS_DocumentID
                        left join dbo.atbl_DCS_Revisions AS R WITH (NOLOCK)
                            on R.Domain = P.Domain
                            and R.DocumentID = P.DocumentID
                ) T
                group by
                    Domain,
                    DocumentID,
                    DtsCurrentRevision,
                    PimsCurrentRevision
        ) U
) V
-- where
--     Dts_Pims_Mismatch = 1
--     or  Dts_Max_Mismatch = 1
--     or  Max_Pims_Mismatch = 1
group by
    Domain,
    Dts_Pims_Mismatch,
    Dts_Max_Mismatch,
    Max_Pims_Mismatch
order by
    Domain,
    Dts_Pims_Mismatch,
    Dts_Max_Mismatch,
    Max_Pims_Mismatch
