select
    activate_link_document =
        '<a href="' +
        'https://pims.akerbp.com/dcs-documents-details?Domain=' +
        PotentialProblems.Domain +
        '&DocID=' +
        PotentialProblems.DocumentID +
        '">' +
        PotentialProblems.DocumentID +
        '</a>',
        PotentialProblems.Domain,
        PotentialProblems.DocumentID,
        PotentialProblems.RevisionItemNo,
        OldValue = (
            select top 1 OldValue
            from [dbo].[atbl_DCS_RevisionsLog] L WITH (NOLOCK)
            where
                L.Domain = R.Domain
                AND L.DocumentID = R.DocumentID
                AND L.RevisionItemNo = R.RevisionItemNo
                and L.FieldName = 'RevisionDate'
                and L.CreatedBy in ('a_kevin', 'af_Integrations_ServiceUser')
                and L.FieldValue is null
            ORDER BY
                Created desc
        )
from
(values
    ('158', 'PH-ME-I-0548-004;7005580;97868', '3'),
    ('158', 'PH-ME-I-0551;7005580;97869', '3'),
    ('162', 'SKA-AK-I-XE-8702-001;7005640;70829', '3'),
    ('162', 'SKA-AK-I-XR-0076-001;7005640;76975', '3'),
    ('162', 'SKA-AK-I-XR-0077-001;7005640;76976', '3'),
    ('162', 'SKA-AK-I-XR-0078-001;7005640;70840', '4'),
    ('162', 'SKA-AK-I-XR-0078-002;7005640;87027', '5'),
    ('162', 'SKA-AK-I-XR-0079-001;7005640;70841', '4'),
    ('162', 'SKA-AK-I-XR-0079-002;7005640;87028', '6'),
    ('162', 'SKA-AK-I-XR-0925-001;7005640;76977', '4'),
    ('162', 'SKA-AK-I-XR-7906-001;7005640;70832', '3'),
    ('162', 'SKA-AK-I-XR-7906-002;7005640;70866', '3'),
    ('162', 'SKA-AK-I-XR-7907-001;7005640;70831', '6'),
    ('162', 'SKA-AK-I-XR-7915-001;7005640;70867', '3'),
    ('162', 'SKA-AK-S-DS-1011;7005640;102060', '4'),
    ('162', 'SKA-ED-I-XL-0008-004;7005640;70839', '5'),
    ('162', 'SKA-ED-I-XL-0009-002;7005640;70836', '4'),
    ('162', 'SKA-SB-I-XI-0010-007;7005640;84711', '1'),
    ('162', 'SKA-SB-P-XB-4301-001;7005640;83823', '4'),
    ('162', 'SKA-SB-P-XB-6301-001;7005640;94001', '5'),
    ('035', '3203-T-FKM-I-XB-20-0004-01;7005547;229765', '4')
 
) PotentialProblems (Domain, DocumentID, RevisionItemNo)
JOIN dbo.atbl_DCS_Revisions R WITH (NOLOCK)
    ON R.Domain = PotentialProblems.Domain
    AND R.DocumentID = PotentialProblems.DocumentID
    AND R.RevisionItemNo = PotentialProblems.RevisionItemNo
WHERE
    (
        R.ApprovalStatus LIKE '%completed%'
        OR R.ApprovalStatus LIKE '%rejected%'
    )