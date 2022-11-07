
{%- call statement('max_partition_date_query', True) -%}
select max(tm_meta_processed_at) as high_watermark
from
    {{ ref("rds_tiller__balance_histories") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}

with

    last_partition as (
        select *
        from {{ ref("rds_tiller__balance_histories") }}
        where cast(tm_meta_processed_at as date) = '{{ max_date }}'

    ),

    scd1 as (
        select
            balance_id as id_tiller_balance,
            json_value(json_meta_attributes.`Account_ID`) as id_tiller_account,
            safe_cast(
                json_value(json_meta_attributes.`Date`) as timestamp
            ) as tm_balance,
            safe_cast(
                json_value(json_meta_attributes.`Balance`) as numeric
            ) as amt_balance,
            case
                when json_value(json_meta_attributes.`Account_Status`) = 'ACTIVE'
                then 1
                else 0
            end as is_account_active,
            safe_cast(
                json_value(json_meta_attributes.`Date_Added`) as timestamp
            ) as tm_balance_added

        from last_partition

        where tm_meta_processed_at = '{{ max_timestamp }}'
    )

select *
from scd1
