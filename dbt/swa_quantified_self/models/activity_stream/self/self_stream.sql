{{
    dbt_utils.union_relations(
        relations=[ref("makes_investment"), ref("makes_purchase")]
    )
}}
