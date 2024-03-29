{{
    dbt_utils.union_relations(
        relations=[
            ref("makes_investment"),
            ref("makes_purchase"),
            ref("recieves_payment"),
            ref("sets_budget"),
            ref("updates_balance"),
            ref("updates_eod_balance"),
            ref("tracks_habit"),
            ref("tracks_say_to_do"),
            ref("tracks_time"),
            ref("creates_project"),
            ref("creates_client"),
        ]
    )
}}
