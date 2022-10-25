
{%- call statement('max_partition_date_query', True) -%}
select max(tm_meta_processed_at) as high_watermark
from
    {{ ref("rds_tiller__transactions") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}

with

    last_partition as (
        select *
        from {{ ref("rds_tiller__transactions") }}
        where cast(tm_meta_processed_at as date) = '{{ max_date }}'

    ),

    scd1 as (
        select
            transaction_id as id_tiller_transaction,
            json_value(json_meta_attributes.`Account_ID`) as id_tiller_account,
            json_value(json_meta_attributes.`Category`) as id_tiller_category,
            safe_cast(
                json_value(json_meta_attributes.`Date`) as timestamp
            ) as tm_transaction,
            json_value(
                json_meta_attributes.`Description`
            ) as str_transaction_description,
            safe_cast(
                json_value(json_meta_attributes.`Amount`) as numeric
            ) as amt_transaction,
            -- json_value(
            -- json_meta_attributes.`Check_Number`
            -- ) as str_transaction_check_number,
            json_value(
                json_meta_attributes.`Full_Description`
            ) as str_tiller_transaction_description_full,
            safe_cast(
                json_value(json_meta_attributes.`Categorized_Date`) as timestamp
            ) as tm_transaction_autocategorized,
            safe_cast(
                json_value(json_meta_attributes.`Date_Added`) as timestamp
            ) as tm_transaction_added,
            tm_meta_processed_at

        from last_partition

        where tm_meta_processed_at = '{{ max_timestamp }}'
    )

select *
from scd1
