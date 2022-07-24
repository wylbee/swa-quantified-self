with
    source as (

        select *, _file_name as str_gcs_file_name from {{ source("gcs_raw", "scores") }}

    ),

    mappings as (

        select * from {{ ref('habit_hex_to_category') }}

    ),

    parsed as (

        select
            *,
            replace(
                substr(
                    str_gcs_file_name,
                    (strpos(str_gcs_file_name, 'LH')),
                    (length(str_gcs_file_name) - strpos(str_gcs_file_name, '.') + 2)
                ),
                '.',
                ''
            ) as id_habit

        from source

    ),

    cleaned as (

        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "date_field_0",
                        "id_habit",
                    ]
                )
            }} as id_track,
            case
                when id_habit = 'L0H24'
                then 'LH024'
                when id_habit = 'LH24'
                then 'LH024'
                when id_habit = 'LH23'
                then 'LH023'
                else id_habit
            end as id_habit,
            {{
                dbt_utils.surrogate_key(
                    [
                        "date_field_0",
                        "double_field_1",
                        "id_habit",
                    ]
                )
            }} as id_meta_row_check_hash,
            date_field_0 as dt_track,
            double_field_1 as val_track_score,
            dt_processed as dt_meta_exported,
            str_gcs_file_name as str_meta_file_name


        from parsed

    ),

    change_event as (

        select
            *,
            case
                when
                    coalesce(
                        lag(id_meta_row_check_hash) over (
                            partition by id_track order by dt_meta_exported
                        ),
                        'new_row'
                    ) != id_meta_row_check_hash
                then dt_meta_exported
            end as dt_meta_change_event

        from cleaned

    ),

    last_change as (

        select
            *,
            min(dt_meta_change_event) over (
                partition by id_meta_row_check_hash
            ) as dt_meta_last_change_event
        from change_event

    ),

    change_reversion as (

        select
            *,
            dense_rank() over (
                partition by id_track
                order by coalesce(dt_meta_change_event, dt_meta_last_change_event)
            ) as val_meta_change_sequence

        from last_change
    ),

    change_id as (
        select *
        except
            (id_meta_row_check_hash),
            {{
                dbt_utils.surrogate_key(
                    ["id_meta_row_check_hash", "val_meta_change_sequence"]
                )
            }} as id_meta_row_check_hash
        from change_reversion


    ),

    final as (

        select *
        except
            (dt_meta_last_change_event, dt_meta_change_event),
            min(dt_meta_change_event) over (
                partition by id_meta_row_check_hash
            ) as dt_meta_last_change_event
        from change_id
    )

select *
from final
order by id_habit, dt_meta_exported
