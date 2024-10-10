

declare
@Param0 nvarchar(50)=N'FPQ-AKSO-N-XG-23054-02',
@Param1 nvarchar(128)=N'128'


SELECT
currentRevision,
dcs_step,
    [Step],
    [Planned],
    [Forecast],
    [ProjectPlantID],
    [ProjectID],
    [ProjectPlantNo],
    [ProjectContractNo],
    -- [ActualRegisteredRevision],
    [ContractorActual],
    T.[PrimKey]
FROM
    (
        select
            DP.Domain,
            DP.DocumentID,
            DP.[Step],
            DP.[Planned],
            DP.[Forecast],
            DP.[ProjectPlantID],
            DP.[ProjectID],
            ProjectPlantNo = P.[PlantNo],
            DP.[ProjectContractNo],
            -- DP.[ActualRegisteredRevision],
            DP.[ContractorActual],
            DP.[PrimKey]
        FROM
            dbo.atbl_DCS_DocumentsPlan AS DP WITH (NOLOCK)
            LEFT JOIN dbo.atbl_Asset_Plants AS P WITH (NOLOCK)
                ON P.PlantID = DP.ProjectPlantID
            left JOIN dbo.atbl_DCS_Steps S WITH (NOLOCK) -- this is not a left join in the UI view, and probably not in other places either
                ON DP.Domain = S.Domain
                AND DP.Step = S.Step
    ) T
    join dbo.ltbl_Import_DTS_DCS_Documents ID with (nolock)
        on ID.DCS_Domain = T.Domain
        and ID.DCS_DocumentID = T.DocumentID
    join dbo.ltbl_Import_DTS_DCS_Revisions AS IR WITH (NOLOCK)
        on IR.DCS_Domain = ID.DCS_Domain
        and IR.DCS_DocumentID = ID.DCS_DocumentID
WHERE
    (
        [DocumentID] = @Param0
        AND [Domain] = @Param1
    )
ORDER BY
    [Step]

