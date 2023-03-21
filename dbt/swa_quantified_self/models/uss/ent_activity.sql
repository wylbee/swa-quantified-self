with

    stream as (select * from {{ ref("self_stream") }}),

    final as (
        select
            activity_id as key_activity,
            ts as tm_activity,
            activity_occurrence as n_activity,
            activity_repeated_at as tm_activity_repeated,
            link as str_activity_url,

            {{ fj_str("str_transaction_description") }},
            {{ fj_n("is_habit_impact") }},
            {{ fj_n("is_habit_planned_rest") }},
            {{ fj_n("is_habit_complete") }},
            {{ fj_n("is_habit_skipped") }},
            {{ fj_amt("val_habit_score") }}

        from stream

    )

select *
from final
