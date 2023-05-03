with
    raw_data as (select * from {{ source("gcs_raw", "projects") }}),

    renamed as (

        select
            id as id_toggl_project,
            cid as id_toggl_client,
            name as str_project_name,
            active as is_project_active,
            `at` as tm_project_created,
            export_date as dt_meta_exported

        from raw_data

    )

select *
from renamed
