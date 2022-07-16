with
    source as (

        select *, _file_name as str_gcs_file_name
        from {{ source("gcs_raw", "checkmarks") }}

    ),

    parsed as (

        select
            *,
            substr(
                str_gcs_file_name,
                (strpos(str_gcs_file_name, 'LH')),
                (length(str_gcs_file_name) - strpos(str_gcs_file_name, '.') + 2)
            ) as id_habit

        from source

    ),

    cleaned as (

        select
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
                        "int64_field_1",
                        "id_habit",
                    ]
                )
            }} as id_meta_row_check_hash,
            date_field_0 as dt_habit_evaluation,
            int64_field_1 as val_habit_evalution,
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
                            partition by id_habit order by dt_meta_exported
                        ),
                        'new_row'
                    ) != id_meta_row_check_hash
                then dt_meta_exported
            end as dt_meta_change_event

        from cleaned

    ),

    final as (

        select *
        except
            (dt_meta_change_event),
            min(dt_meta_change_event) over (
                partition by id_meta_row_check_hash
            ) as dt_meta_last_change_event
        from change_event

    )


select *
from final
order by id_habit, dt_meta_exported
