with
    source as (

        select *, _file_name as str_gcs_file_name from {{ source("gcs_raw", "habits") }}

    ),

    parsed as (

        select
            *,
            substr(
                name, (strpos(name, '[') + 1), (length(name) - strpos(name, '[') -1)
            ) as id_habit

        from source

    ),

    corrected as (

        select *
        except
            (id_habit),
            case
                when id_habit = 'L0H24'
                then 'LH024'
                when id_habit = 'LH24'
                then 'LH024'
                when id_habit = 'LH23'
                then 'LH023'
                else id_habit
            end as id_habit
        from parsed
    ),

    cleaned as (

        select
            id_habit,

            {{
                dbt_utils.surrogate_key(
                    [
                        "Position",
                        "Name",
                        "Question",
                        "Description",
                        "NumRepetitions",
                        "`Interval`",
                        "Color",
                        "id_habit",
                    ]
                )
            }} as id_meta_row_check_hash,

            position as val_habit_position,
            name as str_habit_name,
            question as str_habit_prompt,
            description as str_habit_description,
            numrepetitions as val_habit_target,
            `Interval` as val_habit_interval,
            color as str_habit_color_hex,
            dt_processed as dt_meta_exported,
            str_gcs_file_name as str_meta_file_name

        from corrected

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

    last_change as (

        select *,
            min(dt_meta_change_event) over (
                partition by id_meta_row_check_hash
            ) as dt_meta_last_change_event
        from change_event

    ),

    change_reversion as (

        select 
            *,dense_rank() over (partition by id_habit order by coalesce(dt_meta_change_event,dt_meta_last_change_event)) as val_meta_change_sequence
        
        from last_change
    ),

    change_id as (
        select * except (id_meta_row_check_hash),
                    {{
                dbt_utils.surrogate_key(["id_meta_row_check_hash","val_meta_change_sequence"]) }} as id_meta_row_check_hash
            from change_reversion
                           

    ),

    final as (

        select * except (dt_meta_last_change_event, dt_meta_change_event),
                    min(dt_meta_change_event) over (
                partition by id_meta_row_check_hash
            ) as dt_meta_last_change_event
        from change_id
    )

select *
from final
order by id_habit, dt_meta_exported
