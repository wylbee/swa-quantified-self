with
    raw_data as (select * from {{ source("gcs_raw", "clients") }}),

    renamed as (

        select
            id as id_toggl_client,
            name as str_client_name,
            `at` as tm_client_created,
            export_date as dt_meta_exported

        from raw_data

    )

select *
from renamed
