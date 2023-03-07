with

    base as (select * from {{ ref("base_tiller__categories") }}),

    final as (
        select
            id_tiller_budget as key_budget,
            id_tiller_budget,
            cat_budget_group,
            cat_budget_type,
            is_budget_hidden_from_reporting,
            is_budget_monthly_line,

            case
                when cat_budget_type like '%Income%' then 1 else 0
            end as is_budget_income,

            case
                when cat_budget_group like '%Save%' then 1 else 0
            end as is_budget_save,

            case
                when cat_budget_group like '%Live%' and cat_budget_type != 'Income'
                then 1
                when cat_budget_group like '%Give%' and cat_budget_type != 'Income'
                then 1
                else 0
            end as is_budget_spend

        from base
    )

select *
from final
