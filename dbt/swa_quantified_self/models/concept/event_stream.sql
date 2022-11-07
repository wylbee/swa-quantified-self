{{
    dbt_utils.union_relations(
        relations=[ref("de_receives_payment"), ref("de_purchases_investment")]
    )
}}
