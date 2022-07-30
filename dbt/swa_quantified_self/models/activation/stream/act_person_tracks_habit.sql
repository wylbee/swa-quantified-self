with

    tracks as (select * from {{ ref("sst_tracks") }}),

    habits_cv as (select * from {{ ref("sst_habits") }}),

    habits_scd as (select * from {{ ref("sst_habits") }}),

    activity as (

        select
            cast(tracks.dt_track as datetime) as tm_activity,
            'person_tracks_habit' as cat_activity_type,
            {{ nest_activity_context(is_activity_complete="tracks.is_track") }}
            tracks as nest_tracks,
            struct(habits_cv as cv, habits_scd as scd) as nest_habits

        from tracks

        left outer join
            habits_cv
            on tracks.id_habit = habits_cv.id_habit
            and habits_cv.dt_meta_valid_to is null

        left outer join
            habits_scd
            on tracks.id_habit = habits_scd.id_habit
            and tracks.dt_track >= habits_scd.dt_meta_valid_from
            and tracks.dt_track < coalesce(habits_scd.dt_meta_valid_to, '2099-12-31')

    ),

    final as (

        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "nest_tracks.key_track",
                        "tm_activity",
                        "cat_activity_type",
                    ]
                )
            }} as key_activity,
            *,
            row_number() over (
                partition by order by tm_activity
            ) as n_activity_occurrence,

            lead(tm_activity) over (order by tm_activity) as tm_next_activity

        from activity

    )

select *
from final
