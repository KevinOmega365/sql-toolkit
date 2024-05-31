
select * from
(
    select top 50
        ActivitiesRelations.PrimKey,
        ActivitiesRelations.Activity_ID,
        ActivitiesRelations.RelatedActivity_ID,
        ActivityKeys.ActivityKey,
        BetterKey = case
            when Activity_ID < RelatedActivity_ID
            then cast(Activity_ID as nvarchar(max)) +'#' + cast(RelatedActivity_ID as nvarchar(max))
            else cast(RelatedActivity_ID as nvarchar(max)) +'#' + cast(Activity_ID as nvarchar(max))
        end,
        RelationInstanceCount = ROW_NUMBER() OVER(partition by ActivityKeys.ActivityKey order by ActivitiesRelations.Activity_ID)
    from
    dbo.ltbl_Import_Stage_Planning_ActivitiesRelations ActivitiesRelations WITH (NOLOCK)
    join
    (
        select
            Primkey,
            ActivityKey = string_agg(ActivityKeyPart, '#') within group (order by ActivityKeyPart)
        from
        (
            SELECT
                PrimKey,
                ActivityKeyPart = Activity_ID
            FROM
                dbo.ltbl_Import_Stage_Planning_ActivitiesRelations WITH (NOLOCK)
            where
                Activity_ID is not null

            union all

            SELECT
                PrimKey,
                ActivityKeyPart = RelatedActivity_ID
            FROM
                dbo.ltbl_Import_Stage_Planning_ActivitiesRelations WITH (NOLOCK)
            where
                RelatedActivity_ID is not null
        ) T
        group by PrimKey

    ) ActivityKeys
        on ActivityKeys.PrimKey = ActivitiesRelations.PrimKey
    WHERE
        EXISTS (
            SELECT *
            FROM dbo.ltbl_Import_Stage_Planning_ActivitiesRelations AS InverseRelation WITH (NOLOCK)
            WHERE
                InverseRelation.Activity_ID = ActivitiesRelations.RelatedActivity_ID AND InverseRelation.RelatedActivity_ID = ActivitiesRelations.Activity_ID
        )
) U
where RelationInstanceCount = 2



-- SELECT A.PrimKey, A.Activity_ID, A.RelatedActivity_ID, A.SortKey
-- FROM (
--     SELECT  I.PrimKey, I.Activity_ID, I.RelatedActivity_ID, CAST(I.Activity_ID AS NVARCHAR(MAX)) +'#'+ CAST(I.RelatedActivity_ID AS NVARCHAR(MAX)) AS SortKey
--     FROM
--         dbo.ltbl_Import_Stage_Planning_ActivitiesRelations AS I WITH (NOLOCK)
--     WHERE
--         EXISTS (
--             SELECT *
--             FROM dbo.ltbl_Import_Stage_Planning_ActivitiesRelations AS D WITH (NOLOCK)
--             WHERE
--                 D.Activity_ID = I.RelatedActivity_ID AND D.RelatedActivity_ID = I.Activity_ID
--         )
-- ) AS A
-- ORDER BY A.SortKey