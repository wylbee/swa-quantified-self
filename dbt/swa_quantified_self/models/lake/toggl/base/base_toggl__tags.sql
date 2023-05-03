select * from {{ source("gcs_raw", "tags") }}
