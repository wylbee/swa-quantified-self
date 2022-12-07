with

    transactions as (select * from {{ ref("base_tiller__transactions") }}),

    accounts as (select * from {{ ref("int_finaccount") }}),

    budgets as (select * from {{ ref("int_budget") }}),

    joined as (

        select
            transactions.tm_transaction as tm_event,
            'Person Purchases Goods and Services' as cat_event,
            accounts.key_finaccount,
            budgets.key_budget,
            transactions.amt_transaction as amt_expense,

            transactions.id_tiller_transaction as id_source,
            '{{ var("str_tiller_url") }}' as str_source_url,

            to_json(
                struct(transactions.str_transaction_description)
            ) as json_event_features

        from transactions

        left outer join
            accounts
            on transactions.id_tiller_finaccount = accounts.id_tiller_finaccount

        left outer join
            budgets on transactions.id_tiller_budget = budgets.id_tiller_budget

        where
            accounts.is_finaccount_savings != 1 and budgets.cat_budget_type = 'Expense'

    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source"],
            responsible_subject_column="key_finaccount",
        )
    }}
