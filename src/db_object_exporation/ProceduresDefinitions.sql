select
    ProcedureName = P.Name,
    ProcedureSource = object_definition(object_id)
from
    sys.objects P
where
    P.name like 'astp_TGE_AzureAd%'
    and P.type in ('p')
order by
    ProcedureName
