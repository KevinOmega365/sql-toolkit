/**
 * PONumbers without a description
 */
select *
from dbo.atbl_DCS_ContractsPurchaseOrders with (nolock)
where
    Description = 'TBD'
    and Domain in ('145','128','187','153')
