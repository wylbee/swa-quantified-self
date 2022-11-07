
{%- call statement('max_partition_date_query', True) -%}
select max(tm_meta_processed_at) as high_watermark
from
    {{ ref("rds_tiller__accounts") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}

with

    last_partition as (
        select *
        from {{ ref("rds_tiller__accounts") }}
        where cast(tm_meta_processed_at as date) = '{{ max_date }}'

    ),

    scd1 as (
        select
            account_id as id_tiller_finaccount,
            json_value(json_meta_attributes.`Account`) as str_finaccount_name,
            json_value(json_meta_attributes.`Class_Override`) as cat_finaccount_class,
            json_value(json_meta_attributes.`Group`) as cat_finaccount_group,
            json_value(
                json_meta_attributes.`Institution`
            ) as cat_finaccount_institution,
            json_value(json_meta_attributes.`Type`) as cat_finaccount_institution_type

        from last_partition

        where tm_meta_processed_at = '{{ max_timestamp }}'
    )

select *
from scd1
