with

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    fy_2022 as (

        select
            {{ dbt_utils.surrogate_key(["id_tiller_budget", "'2022'"]) }} as key_budget,
            id_tiller_budget,
            cat_budget_group,
            cat_budget_type,
            is_budget_hidden_from_reporting,

            case
                when cat_budget_group like '%Monthly%' then 1 else 0
            end as is_budget_monthly_line

        from budgets

    ),

    -- union
    final as (select * from fy_2022)

select *
from final
