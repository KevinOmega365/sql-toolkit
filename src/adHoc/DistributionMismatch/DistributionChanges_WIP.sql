
select top 10
    activate_link_document =
        '<a href="' +
        'https://pims.akerbp.com/dcs-documents-details?Domain=' +
        Domain +
        '&DocID=' +
        DocumentID +
        '">' +
        DocumentID +
        '</a>'
from
    (
        select
            Documents.Domain,
            Documents.DocumentID
        from 
            [dbo].[atbl_DCS_Documents] Documents with (nolock)
            join [dbo].[atbl_DCS_DocumentsLog] DocLog with (nolock)
                on DocLog.Domain = Documents.Domain
                and DocLog.DocumentID = Documents.DocumentID
            join [dbo].[atbl_DCS_DistributionSetupLog] as DistLog with (nolock)
                on DistLog.Domain = Documents.Domain
                and DistLog.DocumentID = Documents.DocumentID
        where
            Documents.currentRevision is not null
            and DocLog.Created > dateadd(day, 1, Documents.Created)
            and Documents.CreatedBy = 'af_Integrations_ServiceUser'
            and DocLog.CreatedBy = 'af_Integrations_ServiceUser'
            and DistLog.CreatedBy = 'af_Integrations_ServiceUser'
            and DocLog.FieldName in (
                'AssetCustomText1',
                'DocsCustomText1',
                'DocsCustomText2',
                'DocsCustomText3',
                'DocsCustomText4',
                'Flag',
                'InstanceCustomText2',
                'InstanceCustomText3'
            )
            and Documents.Domain in (
                '128',
                '145',
                '153',
                '175',
                '181',
                '187'
            )
        group by
            Documents.Domain,
            Documents.DocumentID
    ) T
order by
    newid()

-- select count(*) from [dbo].[atbx_DCS_DistributionSetupLog] where CreatedBy = 'af_Integrations_ServiceUser'
