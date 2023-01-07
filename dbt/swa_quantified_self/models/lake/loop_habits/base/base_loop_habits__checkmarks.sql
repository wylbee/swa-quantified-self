
{%- call statement('max_partition_date_query', True) -%}
select max(dt_processed) as high_watermark
from
    {{ source("gcs_raw", "checkmarks") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}


with
    source as (

        select *, _file_name as str_gcs_file_name
        from {{ source("gcs_raw", "checkmarks") }}

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
            ) as id_habit,

        from source

    ),

    final as (

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
                        "int64_field_1",
                        "id_habit",
                    ]
                )
            }} as id_meta_row_check_hash,
            date_field_0 as dt_track,
            int64_field_1 as val_track,
            dt_processed as dt_meta_exported,
            str_gcs_file_name as str_meta_file_name


        from parsed

        where dt_processed = '{{ max_timestamp }}'

    )

select *
from final
order by id_habit, dt_meta_exported
