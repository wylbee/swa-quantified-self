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
            {{ fj_amt("val_habit_score") }},
            {{ fj_amt("val_habit_score_group_weight") }},
            {{ fj_str("cat_area_group") }},
            {{ fj_str("str_time_entry_description") }},
            {{ fj_n("is_tag_meeting") }},
            {{ fj_n("is_tag_deep_work") }},
            {{ fj_n("is_tag_slope_learning") }},
            {{ fj_n("is_tag_most_important_work") }}

        from stream

    )

select *
from final
