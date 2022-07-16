{% snapshot snap_loop_habits__habits %}

{{
    config(
        target_schema="snapshots",
        unique_key="id_habit",
        strategy="timestamp",
        updated_at="dt_processed",
    )
}}

select *
except (str_gcs_file_name)
from {{ ref("corz_loop_habits__habits") }}

where dt_processed = '2022-07-10'  -- '2022-06-12'

{% endsnapshot %}
