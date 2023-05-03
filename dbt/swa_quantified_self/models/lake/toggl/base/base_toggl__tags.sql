with
    raw_data as (select * from {{ source("gcs_raw", "tags") }}),

    renamed as (

        select id as id_toggl_tag, name as str_tag_name, export_date as dt_meta_exported

        from raw_data

        qualify row_number() over (partition by id order by export_date desc) = 1
    )

select *
from renamed
