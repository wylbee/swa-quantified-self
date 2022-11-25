with

    bal as (select * from {{ ref("base_tiller__balance_histories") }}),

    accounts as (select * from {{ ref("int_finaccount") }}),

    joined as (

        select
            bal.tm_balance as tm_event,
            'System assesses Balance' as cat_event,
            accounts.key_finaccount,
            bal.amt_balance * accounts.val_finaccount_class_modifier as amt_balance,
            bal.id_tiller_balance as id_source,
            '{{ var("str_tiller_url") }}' as str_source_url,
            to_json(struct()) as json_event_features

        from bal

        left outer join
            accounts on bal.id_tiller_finaccount = accounts.id_tiller_finaccount
    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source"],
            responsible_subject_column="key_finaccount",
        )
    }}
