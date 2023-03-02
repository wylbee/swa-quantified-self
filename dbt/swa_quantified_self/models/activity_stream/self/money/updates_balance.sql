{{ config(features=["amt_balance"]) }}

with

    bal as (select * from {{ ref("base_tiller__balance_histories") }}),

    accounts as (select * from {{ ref("base_tiller__accounts") }}),

    joined as (

        select
            bal.id_tiller_balance as activity_id,
            bal.tm_balance as ts,
            'self' as customer,
            'updates_balance' as activity,
            to_json_string(
                struct(accounts.id_tiller_finaccount as key_finaccount)
            ) as anonymous_customer_id,

            null as revenue_impact,
            '{{ var("str_tiller_url") }}' as link,

            bal.amt_balance * accounts.val_finaccount_class_modifier as amt_balance

        from bal

        left outer join
            accounts on bal.id_tiller_finaccount = accounts.id_tiller_finaccount

    )

select *
from {{ activity_schema.make_activity("joined") }}
