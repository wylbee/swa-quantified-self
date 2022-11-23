with

    bal as (select * from {{ ref("base_tiller__balance_histories") }}),

    accounts as (select * from {{ ref("int_finaccount") }}),

    joined as (

        select
            bal.tm_balance as tm_event,
            'System assesses Balance' as cat_event,
            to_json(struct(accounts.key_finaccount)) as json_event_entities,
            to_json(
                struct(
                    bal.amt_balance
                    * accounts.val_finaccount_class_modifier as amt_balance
                )
            ) as json_event_features,
            to_json(
                struct(
                    bal.id_tiller_balance,
                    '{{ var("str_tiller_url") }}' as str_source_url
                )
            ) as json_event_source

        from bal

        left outer join
            accounts on bal.id_tiller_finaccount = accounts.id_tiller_finaccount
    ),

    final as (
        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "json_value(json_event_source.id_tiller_balance)",
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
