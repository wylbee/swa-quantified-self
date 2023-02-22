{{ config(features=["str_transaction_description", "amt_invested", "amt_income"]) }}

with

    transactions as (select * from {{ ref("base_tiller__transactions") }}),

    accounts as (select * from {{ ref("base_tiller__accounts") }}),

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    joined as (

        select
            transactions.id_tiller_transaction as activity_id,
            transactions.tm_transaction as ts,
            'self' as customer,
            'makes_investment' as activity,
            to_json_string(
                struct(
                    accounts.id_tiller_finaccount as key_finaccount,
                    budgets.id_tiller_budget as key_budget
                )
            ) as anonymous_customer_id,

            case
                when budgets.cat_budget_type = 'Income'
                then transactions.amt_transaction
            end as revenue_impact,


            '{{ var("str_tiller_url") }}' as link,

            transactions.str_transaction_description,
            transactions.amt_transaction as amt_invested,
            case
                when budgets.cat_budget_type = 'Income'
                then transactions.amt_transaction
            end as amt_income


        from transactions

        left outer join
            accounts
            on transactions.id_tiller_finaccount = accounts.id_tiller_finaccount

        left outer join
            budgets on transactions.id_tiller_budget = budgets.id_tiller_budget

        where
            accounts.is_finaccount_savings = 1
            and budgets.id_tiller_budget not in ('Excluded Line', 'Investment Fees')

    )

select *
from {{ activity_schema.make_activity("joined") }}
