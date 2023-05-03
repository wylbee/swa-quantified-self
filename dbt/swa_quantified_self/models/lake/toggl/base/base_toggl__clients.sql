select * from {{ source("gcs_raw", "clients") }}
