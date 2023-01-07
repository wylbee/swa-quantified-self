
{%- call statement('max_partition_date_query', True) -%}
select max(dt_processed) as high_watermark
from
    {{ source("gcs_raw", "habits") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}


with
    source as (

        select *, _file_name as str_gcs_file_name from {{ source("gcs_raw", "habits") }}

    ),

    mappings as (select * from {{ ref("habit_hex_to_category") }}),

    parsed as (

        select
            *,
            substr(
                name, (strpos(name, '[') + 1), (length(name) - strpos(name, '[') -1)
            ) as id_habit

        from source

    ),

    corrected as (

        select
            * except (id_habit),
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

        where dt_processed = '{{ max_timestamp }}'

    ),

    joined as (

        select cleaned.*, mappings.cat_habit_grouping

        from cleaned

        left outer join
            mappings on cleaned.str_habit_color_hex = mappings.str_habit_color_hex

    )

select *
from joined
order by id_habit, dt_meta_exported
