with

    budgets as (select * from {{ ref("int_budget") }}),

    calendar as (select * from {{ ref("int_calendar") }}),

    start_end as (

        select
            key_budget,
            min(date(val_budget_fiscal_year, 1, 1)) as dt_min,
            max(date(val_budget_fiscal_year, 12, 31)) as dt_max
        from budgets
        group by 1
    ),

    grain as (

        select calendar.key_calendar, start_end.key_budget

        from calendar

        inner join
            start_end
            on calendar.key_calendar >= start_end.dt_min
            and calendar.key_calendar <= start_end.dt_max

        where calendar.val_calendar_day = 1
    ),

    at_grain as (

        select grain.key_calendar, grain.key_budget, budgets.* except (key_budget)

        from grain

        left outer join
            budgets
            on extract(year from grain.key_calendar) = budgets.val_budget_fiscal_year
            and grain.key_budget = budgets.key_budget

    ),

    joined as (

        select
            cast(key_calendar as timestamp) as tm_event,
            'Person Sets Budget' as cat_event,
            key_budget,
            key_calendar,
            amt_budget_monthly as amt_budget,
            id_tiller_budget as id_source,
            '{{ var("str_tiller_url") }}' as str_source_url,
            to_json(struct()) as json_event_features

        from at_grain

    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source", "tm_event"],
            responsible_subject_column="key_budget",
        )
    }}
