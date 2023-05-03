select * from {{ source("gcs_raw", "projects") }}
