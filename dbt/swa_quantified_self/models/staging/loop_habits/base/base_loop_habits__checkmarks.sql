select *, _FILE_NAME as f from {{ source('gcs_raw','checkmarks')}}