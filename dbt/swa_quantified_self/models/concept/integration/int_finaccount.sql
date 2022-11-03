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
                        'Emergency Fund',
                        'Retirement Savings',
                        'Health Savings'
                    )
                then 1
                else 0
            end as is_finaccount_savings

        from accounts
    )

select *
from final
