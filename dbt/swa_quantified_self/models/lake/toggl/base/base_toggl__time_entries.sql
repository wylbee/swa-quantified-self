with
    raw_data as (select * from {{ source("gcs_raw", "time_entries") }}),

    renamed as (

        select
            id as id_toggl_time_entry,
            pid as id_toggl_project,

            description as str_time_entry_description,
            dur / 60000 as amt_time_entry_duration_minutes,

            updated as tm_time_entry_updated,
            `start` as tm_time_entry_started,
            `end` as tm_time_entry_ended,

            export_date as dt_meta_exported

        from raw_data

        qualify row_number() over (partition by id order by export_date desc) = 1

    )

select *
from renamed
