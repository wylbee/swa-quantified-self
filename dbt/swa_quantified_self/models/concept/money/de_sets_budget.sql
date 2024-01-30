with

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    int_budgets as (select * from {{ ref("int_budget") }}),

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
                    amt_budget_2023_12,
                    amt_budget_2024_01,
                    amt_budget_2024_02,
                    amt_budget_2024_03,
                    amt_budget_2024_04,
                    amt_budget_2024_05,
                    amt_budget_2024_06,
                    amt_budget_2024_07,
                    amt_budget_2024_08,
                    amt_budget_2024_09,
                    amt_budget_2024_10,
                    amt_budget_2024_11,
                    amt_budget_2024_12
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

        select
            int_budgets.*,
            renamed.* except (id_tiller_budget),
            date(val_budget_year, val_budget_month, 1) as key_calendar

        from renamed

        left outer join
            int_budgets on renamed.id_tiller_budget = int_budgets.id_tiller_budget

    ),

    prepped as (

        select
            cast(key_calendar as timestamp) as tm_event,
            'Person Sets Budget' as cat_event,
            key_budget,
            amt_budget,
            id_tiller_budget as id_source,
            '{{ var("str_tiller_url") }}' as str_source_url,
            to_json(struct()) as json_event_features

        from joined

    ),

    {{
        generate_final_event_cte(
            prev_cte_name="prepped",
            surrogate_key_columns=["key_budget", "tm_event"],
            responsible_subject_column="key_budget",
        )
    }}
