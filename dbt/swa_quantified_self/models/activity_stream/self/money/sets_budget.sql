{{ config(features=["amt_budget"]) }}

with

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    unpivoted as (

        select *
        from
            budgets unpivot (
                amt_budget for cat_budget_month_year in (
                    amt_budget_2022_08,
                    amt_budget_2022_09,
                    amt_budget_2022_10,
                    amt_budget_2022_11,
                    amt_budget_2022_12,
                    amt_budget_2023_01,
                    amt_budget_2023_02,
                    amt_budget_2023_03,
                    amt_budget_2023_04,
                    amt_budget_2023_05,
                    amt_budget_2023_06,
                    amt_budget_2023_07,
                    amt_budget_2023_08,
                    amt_budget_2023_09,
                    amt_budget_2023_10,
                    amt_budget_2023_11,
                    amt_budget_2023_12
                )
            )
    ),

    renamed as (

        select
            cast(
                left(right(cat_budget_month_year, 7), 4) as integer
            ) as val_budget_year,
            cast(right(cat_budget_month_year, 2) as integer) as val_budget_month,
            id_tiller_budget,
            amt_budget

        from unpivoted

    ),

    joined as (

        select renamed.*, date(val_budget_year, val_budget_month, 1) as key_calendar

        from renamed

    ),

    prepped as (

        select
            concat(
                cast(key_calendar as string), ' | ', id_tiller_budget
            ) as activity_id,
            cast(key_calendar as timestamp) as ts,
            'self' as customer,
            'sets_budget' as activity,
            to_json_string(
                struct(id_tiller_budget as key_budget)
            ) as anonymous_customer_id,
            null as revenue_impact,
            '{{ var("str_tiller_url") }}' as link,
            amt_budget

        from joined

    )

select *
from {{ activity_schema.make_activity("prepped") }}
