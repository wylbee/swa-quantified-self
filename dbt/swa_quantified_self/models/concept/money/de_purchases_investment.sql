with

    transactions as (select * from {{ ref("base_tiller__transactions") }}),

    accounts as (select * from {{ ref("int_finaccount") }}),

    budgets as (select * from {{ ref("int_budget") }}),

    joined as (

        select
            transactions.tm_transaction as tm_event,
            'Person Purchases Investment' as cat_event,
            to_json(
                struct(accounts.key_finaccount, budgets.key_budget)
            ) as json_event_entities,
            to_json(
                struct(
                    transactions.str_transaction_description,
                    transactions.amt_transaction as amt_invested,
                    case
                        when budgets.cat_budget_type = 'Income'
                        then transactions.amt_transaction
                    end as amt_income
                )
            ) as json_event_features,
            to_json(
                struct(
                    transactions.id_tiller_transaction,
                    '{{ var("str_tiller_url") }}' as str_source_url
                )
            ) as json_event_source

        -- contents
        from transactions

        left outer join
            accounts
            on transactions.id_tiller_finaccount = accounts.id_tiller_finaccount

        left outer join
            budgets
            on transactions.id_tiller_budget = budgets.id_tiller_budget
            and extract(year from transactions.tm_transaction)
            = budgets.val_budget_fiscal_year

        where
            accounts.is_finaccount_savings = 1
            and budgets.id_tiller_budget not in ('Excluded Line', 'Investment Fees')

    ),

    final as (
        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "json_value(json_event_source.id_tiller_transaction)",
                    ]
                )
            }} as key_event,
            *,
            row_number() over (
                partition by json_value(json_event_entities.key_finaccount)
                order by tm_event
            ) as n_event_occurrence,

            lead(tm_event) over (
                partition by json_value(json_event_entities.key_finaccount)
                order by tm_event
            ) as tm_next_event
        from joined

    )

select *
from final
