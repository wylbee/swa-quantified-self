with

    accounts as (select * from {{ ref("base_tiller__accounts") }}),

    final as (

        select
            {{
                dbt_utils.surrogate_key(
                    [
                        "id_tiller_finaccount",
                    ]
                )
            }} as key_finaccount,
            *,
            case
                when
                    cat_finaccount_group in (
                        'LT Savings',
                        'SMT Savings',
                        'Retirement Savings',
                        'Health Savings'
                    )
                then 1
                else 0
            end as is_finaccount_savings,

            case
                when cat_finaccount_class = 'Liability'
                then -1
                when cat_finaccount_class = 'Asset'
                then 1
            end as val_finaccount_class_modifier

        from accounts
    )

select *
from final
