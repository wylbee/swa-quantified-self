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
            }} as key_finaccount, *

        from accounts
    )

select *
from final
