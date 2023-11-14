-- select InstanceCount = count(*), INTEGR_REC_GROUPREF, owner
-- from dbo.ltbl_Import_ProArc_Documents with (nolock)
-- group by
--     INTEGR_REC_GROUPREF,
--     owner
-- order by
--     INTEGR_REC_GROUPREF,
--     InstanceCount desc,
--     owner

-- select InstanceCount = count(*), INTEGR_REC_GROUPREF, HasOwner,INTEGR_REC_STATUS
-- from
-- (
--     select
--         INTEGR_REC_GROUPREF,
--         INTEGR_REC_STATUS,
--         HasOwner = cast(case when owner is not null then 1 else 0 end as bit)
--     from
--         dbo.ltbl_Import_ProArc_Documents with (nolock)
-- ) T
-- where
--     INTEGR_REC_GROUPREF = '8770e32a-670b-499e-bb64-586b147019be'
-- group by
--     INTEGR_REC_GROUPREF,
--     INTEGR_REC_STATUS,
--     HasOwner

-- select InstanceCount = count(*), INTEGR_REC_GROUPREF, HasOwner
-- from
-- (
--     select
--         INTEGR_REC_GROUPREF,
--         HasOwner = cast(case when owner is not null then 1 else 0 end as bit)
--     from
--         dbo.ltbl_Import_ProArc_Documents with (nolock)
-- ) T
-- where
--     INTEGR_REC_GROUPREF = '8770e32a-670b-499e-bb64-586b147019be'
-- group by
--     INTEGR_REC_GROUPREF,
--     HasOwner

-- select distinct owner
-- from
--     dbo.ltbl_Import_ProArc_Documents with (nolock)
-- where
--     INTEGR_REC_GROUPREF = '8770e32a-670b-499e-bb64-586b147019be'
--     and owner is not null

-- select
-- owner
-- from (
--     select distinct owner
--     from
--         dbo.ltbl_Import_ProArc_Documents with (nolock)
--     where
--         INTEGR_REC_GROUPREF = '8770e32a-670b-499e-bb64-586b147019be'
--         and owner is not null
-- ) T

/**
 * todo: string split and maybe match against users
 */