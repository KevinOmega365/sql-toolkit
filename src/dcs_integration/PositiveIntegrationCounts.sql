/**
 * Positive integration counts
 */

/**
 * Count document creation
 */
select count(*)
from dbo.atbl_DCS_Documents D with (nolock)
where
    CreatedBy like 'af_Integrations_ServiceUser'
    and Created > dateadd(week, -1, getdate())
    and Domain = '181'

/**
 * Count document updates
 */
select count(*)
from dbo.atbl_DCS_Documents D with (nolock)
where
    Created < dateadd(week, -1, getdate())
    and UpdatedBy like 'af_Integrations_ServiceUser'
    and Updated > dateadd(week, -1, getdate())
    and Domain = '181'

/**
 * Count revision creation
 */
select count(*)
from dbo.atbl_DCS_Revisions R with (nolock)
where
    CreatedBy like 'af_Integrations_ServiceUser'
    and Created > dateadd(week, -1, getdate())
    and Domain = '181'

/**
 * Count revision file creation
 */
select count(*)
from dbo.atbl_DCS_RevisionsFiles RF with (nolock)
where
    CreatedBy like 'af_Integrations_ServiceUser'
    and Created > dateadd(week, -1, getdate())
    and Domain = '181'