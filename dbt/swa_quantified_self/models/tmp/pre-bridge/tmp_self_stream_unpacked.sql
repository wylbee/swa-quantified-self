with

    self_stream as (select * from {{ ref("self_stream") }}),

    parsed as (

        select
            activity_id as key_activity,
            customer as key_self,
            {{ acid_str("key_finaccount") }},
            {{ acid_str("key_budget") }},
            {{ acid_str("key_habit") }},
            cast(ts as date) as key_calendar,
            activity as cat_source,

            revenue_impact as amt_activity_cash_flow_impact,
            {{ fj_amt("amt_income") }},
            {{ fj_amt("amt_invested") }},
            {{ fj_amt("amt_expense") }},
            {{ fj_amt("amt_budget") }},
            {{ fj_amt("amt_balance") }},
            {{ fj_amt("amt_balance_lv") }},
            {{ fj_n("is_habit_impact") }},
            {{ fj_amt("n_say_wc") }},
            {{ fj_amt("n_do_wc") }},
            {{ fj_amt("n_say_nwc") }},
            {{ fj_amt("n_do_nwc") }},
            {{ fj_amt("n_say") }},
            {{ fj_amt("n_do") }}

        from self_stream

    )

select *
from parsed
