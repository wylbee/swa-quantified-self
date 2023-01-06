with

    tracks as (

        select *
        from {{ ref("base_loop_habits__checkmarks") }}

        where dt_meta_valid_to is null

    ),

    scores as (

        select *
        from {{ ref("base_loop_habits__scores") }}

        where dt_meta_valid_to is null

    ),

    joined as (

        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "tracks.id_meta_row_check_hash",
                        "scores.id_meta_row_check_hash",
                    ]
                )
            }} as key_track,

            tracks.id_track,
            tracks.id_habit,
            tracks.dt_track,
            tracks.val_track,
            scores.val_track_score,
            case
                when tracks.val_track = 2
                then 1
                when tracks.id_habit = 'LH024' and tracks.val_track = 5000
                then 1
                else 0
            end as is_track_completed,
            case when tracks.val_track = 1 then 1 else 0 end as is_track_planned_rest,
            tracks.id_meta_row_check_hash as id_meta_tracks_row_check_hash,
            scores.id_meta_row_check_hash as id_meta_scores_row_check_hash

        from tracks

        left outer join scores on tracks.id_track = scores.id_track

    ),

    final as (

        select
            *,
            case
                when is_track_completed = 1 or is_track_planned_rest = 1 then 1 else 0
            end as is_track
        from joined
    )
select *
from final
