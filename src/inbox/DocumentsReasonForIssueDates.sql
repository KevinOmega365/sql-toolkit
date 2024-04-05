
with DocumentsReasonForIssues as (

    select
        DCS_Domain,
        DCS_DocumentID,
        ReasonForIssue
    from
        (

                select
                    DCS_Domain,
                    DCS_DocumentID,
                    ReasonForIssue = json_value(AI.value, '$.reasonForIssue'),
                    IssueDate = json_value(AI.value, '$.issueDate')
                from
                    dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
                    cross apply openjson(actualIssues) AI

            union all

                select
                    DCS_Domain,
                    DCS_DocumentID,
                    ReasonForIssue = json_value(FI.value, '$.reasonForIssue'),
                    IssueDate = json_value(FI.value, '$.issueDate')
                from
                    dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
                    cross apply openjson(forecastIssues) FI

            union all

                select
                    DCS_Domain,
                    DCS_DocumentID,
                    ReasonForIssue = json_value(PI.value, '$.reasonForIssue'),
                    IssueDate = json_value(PI.value, '$.issueDate')
                from
                    dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
                    cross apply openjson(plannedIssues) PI
                    
        ) T
    
    group by
        DCS_Domain,
        DCS_DocumentID,
        ReasonForIssue
)

select
    DocumentsReasonForIssues.DCS_Domain,
    DocumentsReasonForIssues.DCS_DocumentID,
    DocumentsReasonForIssues.ReasonForIssue,
    ActualIssueDate = ActualIssues.IssueDate,
    ForecastIssueDate = ForecastIssues.IssueDate,
    PlannedIssueDate = PlannedIssues.IssueDate
from
    DocumentsReasonForIssues

    left join
    (
        select
            DCS_Domain,
            DCS_DocumentID,
            ReasonForIssue = json_value(AI.value, '$.reasonForIssue'),
            IssueDate = json_value(AI.value, '$.issueDate')
        from
            dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
            cross apply openjson(actualIssues) AI
    )
    as ActualIssues
        on DocumentsReasonForIssues.DCS_Domain = ActualIssues.DCS_Domain
        and DocumentsReasonForIssues.DCS_DocumentID = ActualIssues.DCS_DocumentID
        and DocumentsReasonForIssues.ReasonForIssue = ActualIssues.ReasonForIssue

    left join
    (
        select
            DCS_Domain,
            DCS_DocumentID,
            ReasonForIssue = json_value(FI.value, '$.reasonForIssue'),
            IssueDate = json_value(FI.value, '$.issueDate')
        from
            dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
            cross apply openjson(forecastIssues) FI
    )
    as ForecastIssues
        on DocumentsReasonForIssues.DCS_Domain = ForecastIssues.DCS_Domain
        and DocumentsReasonForIssues.DCS_DocumentID = ForecastIssues.DCS_DocumentID
        and DocumentsReasonForIssues.ReasonForIssue = ForecastIssues.ReasonForIssue

    left join
    (
        select
            DCS_Domain,
            DCS_DocumentID,
            ReasonForIssue = json_value(PI.value, '$.reasonForIssue'),
            IssueDate = json_value(PI.value, '$.issueDate')
        from
            dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
            cross apply openjson(plannedIssues) PI
    )
    as PlannedIssues
        on DocumentsReasonForIssues.DCS_Domain = PlannedIssues.DCS_Domain
        and DocumentsReasonForIssues.DCS_DocumentID = PlannedIssues.DCS_DocumentID
        and DocumentsReasonForIssues.ReasonForIssue = PlannedIssues.ReasonForIssue
