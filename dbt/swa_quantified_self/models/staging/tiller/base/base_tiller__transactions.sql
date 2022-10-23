
{%- call statement('max_partition_date_query', True) -%}
select max(cast(tm_meta_processed_at as date)) as max_partition_date
from
    {{ ref("rds_tiller__transactions") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}

with

    rds as (
        select *
        from {{ ref("rds_tiller__transactions") }}
        where cast(tm_meta_processed_at as date) = '{{ max_date }}'

    ),

    last_processed as (

        select max(tm_meta_processed_at) as tm_meta_last_processed from rds
    ),

    scd1 as (

        select *
        from rds
        where tm_meta_processed_at = (select tm_meta_last_processed from last_processed)
    )

select *
from scd1
