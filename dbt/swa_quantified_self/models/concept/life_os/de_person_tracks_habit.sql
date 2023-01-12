with

    tracks as (select * from {{ ref("base_loop_habits__checkmarks") }}),

    scores as (select * from {{ ref("base_loop_habits__scores") }}),

    habits as (select * from {{ ref("int_habit") }}),

    joined as (

        select
            cast(tracks.dt_track as timestamp) as tm_event,
            'Person tracks Habit' as cat_event,
            habits.key_habit,
            null as str_source_url,
            tracks.id_track as id_source,
            to_json(struct()) as json_event_features,

            case when tracks.val_track > 0 then 1 else 0 end as is_habit_impact,

            case when tracks.val_track = 1 then 1 else 0 end as is_habit_planned_rest,

            case when tracks.val_track = 2 then 1 else 0 end as is_habit_complete,

            case when tracks.val_track = 3 then 1 else 0 end as is_habit_skipped,

            scores.val_track_score

        from tracks

        left outer join
            scores
            on tracks.id_habit = scores.id_habit
            and tracks.dt_track = scores.dt_track

        left outer join habits on tracks.id_habit = habits.id_habit

        where tracks.dt_track < tracks.dt_meta_exported

    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source"],
            responsible_subject_column="key_habit",
        )
    }}
