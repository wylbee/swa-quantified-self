with

    budgets as (select * from {{ ref("base_tiller__categories") }}),

    fy_2022 as (

        select
            {{ dbt_utils.surrogate_key(["id_tiller_budget", "'2022'"]) }} as key_budget,
            id_tiller_budget,
            cat_budget_group,
            cat_budget_type,
            is_budget_hidden_from_reporting,

            cast(2022 as int64) as val_budget_fiscal_year,

            case
                when cat_budget_group = 'Monthly Expenses' then 1 else 0
            end as is_budget_monthly_line,

            amt_budget_2022_08 as val_budget_monthly,
            amt_budget_2022_08 * 12 as val_budget_yearly

        from budgets

    ),

    -- union
    final as (select * from fy_2022)

select *
from final
