{{
    config(
        features=[
            "is_habit_impact",
            "is_habit_planned_rest",
            "is_habit_complete",
            "is_habit_skipped",
            "val_habit_score",
            "val_habit_score_group_weight",
        ]
    )
}}

with

    tracks as (select * from {{ ref("base_loop_habits__checkmarks") }}),

    scores as (select * from {{ ref("base_loop_habits__scores") }}),

    habits as (select * from {{ ref("base_loop_habits__habits") }}),

    joined as (

        select
            tracks.id_track as activity_id,
            cast(tracks.dt_track as timestamp) as ts,
            'self' as customer,
            'tracks_habit' as activity,
            to_json_string(
                struct(habits.id_habit as key_habit)
            ) as anonymous_customer_id,

            null as link,
            null as revenue_impact,

            case when tracks.val_track > 0 then 1 else 0 end as is_habit_impact,

            case when tracks.val_track = 1 then 1 else 0 end as is_habit_planned_rest,

            case when tracks.val_track = 2 then 1 else 0 end as is_habit_complete,

            case when tracks.val_track = 3 then 1 else 0 end as is_habit_skipped,

            scores.val_track_score as val_habit_score,

            1 / count(tracks.id_habit) over (
                partition by tracks.dt_track, habits.cat_habit_grouping
            ) as val_habit_score_group_weight


        from tracks

        left outer join
            scores
            on tracks.id_habit = scores.id_habit
            and tracks.dt_track = scores.dt_track

        left outer join habits on tracks.id_habit = habits.id_habit

        where tracks.dt_track < tracks.dt_meta_exported

    )

select *
from {{ activity_schema.make_activity("joined") }}
