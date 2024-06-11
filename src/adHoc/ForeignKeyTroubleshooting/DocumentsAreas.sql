SELECT distinct
    DCS_Domain
    , DCS_Area
    , Area
from
    dbo.ltbl_Import_DTS_DCS_Documents D with (nolock)
    left join dbo.atbl_Asset_Areas AS A WITH (NOLOCK)
        on A.Area = D.DCS_Area
    