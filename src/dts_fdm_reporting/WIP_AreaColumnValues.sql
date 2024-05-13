declare @groupRef uniqueidentifier = 'efd3449e-3a44-4c38-b0e7-f57ca48cf8b0'

/**
 * Matched vs changing value counts
 */
--todo

/**
 * Null vs non-null in Pims and Import
 */
--todo

/**
 * Deletions and creations: values to and from null
 */

/**
 * Values not in configuration
 */
select distinct DCS_Area
from dbo.ltbl_Import_DTS_DCS_Documents I with (nolock)
where
    not exists (
        select Area
        from dbo.atbl_Asset_Areas A with (nolock)
        where A.Area = I.DCS_Area
    )
    and I.INTEGR_REC_GROUPREF = @groupRef