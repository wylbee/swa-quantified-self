with
    raw_data as (select * from {{ source("gcs_raw", "time_entries") }}),

    renamed as (

        select
            id as id_toggl_time_entry,
            pid as id_toggl_project,
            tags as array_tag_name,

            description as str_time_entry_description,
            dur / 60000 as amt_time_entry_duration_minutes,

            case
                when array_to_string(tags, '|') like '%meeting%' then 1 else 0
            end as is_tag_meeting,

            case
                when array_to_string(tags, '|') like '%deep-work%' then 1 else 0
            end as is_tag_deep_work,

            case
                when array_to_string(tags, '|') like '%slope-learning%' then 1 else 0
            end as is_tag_slope_learning,

            case
                when array_to_string(tags, '|') like '%most-important-work%'
                then 1
                else 0
            end as is_tag_most_important_work,

            updated as tm_time_entry_updated,
            `start` as tm_time_entry_started,
            `end` as tm_time_entry_ended,

            export_date as dt_meta_exported

        from raw_data

        qualify row_number() over (partition by id order by export_date desc) = 1

    )

select *
from renamed
