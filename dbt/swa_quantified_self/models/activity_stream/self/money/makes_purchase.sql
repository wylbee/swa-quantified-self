{{ config(features=["str_transaction_description", "amt_expense"]) }}

with

    transactions as (select * from {{ ref("base_tiller__transactions") }}),

    accounts as (select * from {{ ref("base_tiller__accounts") }}),

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    joined as (

        select
            transactions.id_tiller_transaction as activity_id,
            transactions.tm_transaction as ts,
            'self' as customer,
            'makes_purchase' as activity,
            to_json_string(
                struct(
                    accounts.id_tiller_finaccount as key_finaccount,
                    budgets.id_tiller_budget as key_budget
                )
            ) as anonymous_customer_id,
            '{{ var("str_tiller_url") }}' as link,
            transactions.str_transaction_description,
            case
                when budgets.id_tiller_budget = '529 Plan'
                then -1 * transactions.amt_transaction
                else transactions.amt_transaction
            end as amt_expense

        from transactions

        left outer join
            accounts
            on transactions.id_tiller_finaccount = accounts.id_tiller_finaccount

        left outer join
            budgets on transactions.id_tiller_budget = budgets.id_tiller_budget

        where
            accounts.is_finaccount_savings != 1
            and (
                budgets.cat_budget_type = 'Expense'
                or budgets.id_tiller_budget = '529 Plan'
            )

    ),

    derived as (select *, amt_expense as revenue_impact from joined)

select *
from {{ activity_schema.make_activity("derived") }}
