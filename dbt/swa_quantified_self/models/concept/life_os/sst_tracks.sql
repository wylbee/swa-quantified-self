with

    tracks as (

        select *
        from {{ ref("scd2_loop_habits__checkmarks") }}

        where dt_meta_valid_to is null

    ),

    scores as (

        select *
        from {{ ref("scd2_loop_habits__scores") }}

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
            }} as key_tracks,

            tracks.id_track,
            tracks.id_habit,
            tracks.dt_track,
            tracks.val_track,
            scores.val_track_score,
            tracks.id_meta_row_check_hash as id_meta_tracks_row_check_hash,
            scores.id_meta_row_check_hash as id_meta_scores_row_check_hash

        from tracks

        left outer join scores on tracks.id_track = scores.id_track

    )

select *
from joined
