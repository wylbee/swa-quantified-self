
{%- call statement('max_partition_date_query', True) -%}
select max(tm_meta_processed_at) as high_watermark
from
    {{ ref("rds_tiller__categories") }}
    {%- endcall -%}

    {%- set max_timestamp = load_result("max_partition_date_query")["data"][0][0] -%}
    {%- set max_date = max_timestamp.strftime("%Y-%m-%d") -%}

with

    last_partition as (
        select *
        from {{ ref("rds_tiller__categories") }}
        where cast(tm_meta_processed_at as date) = '{{ max_date }}'

    ),

    scd1 as (
        select
            category as id_tiller_budget,
            json_value(json_meta_attributes.`Group`) as cat_budget_group,
            json_value(json_meta_attributes.`Type`) as cat_budget_type,
            case
                when json_value(json_meta_attributes.`Hide_From_Reports`) = 'Hide'
                then 1
                else 0
            end as is_budget_hidden_from_reporting,
            round(
                safe_cast(json_value(json_meta_attributes.`Aug_2022`) as numeric), 2
            ) as amt_budget_2022_08,
            round(
                safe_cast(json_value(json_meta_attributes.`Sep_2022`) as numeric), 2
            ) as amt_budget_2022_09,
            round(
                safe_cast(json_value(json_meta_attributes.`Oct_2022`) as numeric), 2
            ) as amt_budget_2022_10,
            round(
                safe_cast(json_value(json_meta_attributes.`Nov_2022`) as numeric), 2
            ) as amt_budget_2022_11,
            round(
                safe_cast(json_value(json_meta_attributes.`Dec_2022`) as numeric), 2
            ) as amt_budget_2022_12,
            round(
                safe_cast(json_value(json_meta_attributes.`Jan_2023`) as numeric), 2
            ) as amt_budget_2023_01,
            round(
                safe_cast(json_value(json_meta_attributes.`Feb_2023`) as numeric), 2
            ) as amt_budget_2023_02,
            round(
                safe_cast(json_value(json_meta_attributes.`Mar_2023`) as numeric), 2
            ) as amt_budget_2023_03,
            round(
                safe_cast(json_value(json_meta_attributes.`Apr_2023`) as numeric), 2
            ) as amt_budget_2023_04,
            round(
                safe_cast(json_value(json_meta_attributes.`May_2023`) as numeric), 2
            ) as amt_budget_2023_05,
            round(
                safe_cast(json_value(json_meta_attributes.`Jun_2023`) as numeric), 2
            ) as amt_budget_2023_06,
            round(
                safe_cast(json_value(json_meta_attributes.`Jul_2023`) as numeric), 2
            ) as amt_budget_2023_07,
            round(
                safe_cast(json_value(json_meta_attributes.`Aug_2023`) as numeric), 2
            ) as amt_budget_2023_08,
            round(
                safe_cast(json_value(json_meta_attributes.`Sep_2023`) as numeric), 2
            ) as amt_budget_2023_09,
            round(
                safe_cast(json_value(json_meta_attributes.`Oct_2023`) as numeric), 2
            ) as amt_budget_2023_10,
            round(
                safe_cast(json_value(json_meta_attributes.`Nov_2023`) as numeric), 2
            ) as amt_budget_2023_11,
            round(
                safe_cast(json_value(json_meta_attributes.`Dec_2023`) as numeric), 2
            ) as amt_budget_2023_12


        from last_partition

        where tm_meta_processed_at = '{{ max_timestamp }}'
    )

select *
from scd1
