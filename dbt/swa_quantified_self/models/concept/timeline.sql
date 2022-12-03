with
    unioned as (
        {{
            dbt_utils.union_relations(
                relations=[
                    ref("de_receives_payment"),
                    ref("de_purchases_investment"),
                    ref("de_assesses_balance"),
                    ref("re_measures_eod_finaccount"),
                    ref("de_sets_budget"),
                ]
            )
        }}
    )

select *
from unioned
order by tm_event desc
