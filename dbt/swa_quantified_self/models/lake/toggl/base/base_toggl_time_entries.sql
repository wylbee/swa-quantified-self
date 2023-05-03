select * from {{ source("gcs_raw", "time_entries") }}
