{{
    config(
        materialized="incremental",
        unique_key="id_meta_row_check_hash",
        merge_update_columns=["dt_meta_valid_to"],
    )
}}


with
    all_or_new as (

        select *
        from {{ ref("corz_loop_habits__habits") }}

        {% if is_incremental() %}

        where
            dt_meta_exported >= datetime_sub(
                cast(
                    (select max(dt_meta_last_change_event) from {{ this }}) as datetime
                ),
                interval 1 day
            )

        {% endif %}

    ),

    dates as (

        select
            id_habit,
            id_meta_row_check_hash,
            dt_meta_last_change_event,
            lead(dt_meta_last_change_event) over (
                partition by id_habit order by dt_meta_last_change_event
            ) as dt_meta_next_change_event

        from all_or_new

        group by 1, 2, 3

    ),

    final as (

        select
            all_or_new.*,
            dates.dt_meta_last_change_event as dt_meta_valid_from,
            dt_meta_next_change_event as dt_meta_valid_to

        from all_or_new

        left outer join
            dates on all_or_new.id_meta_row_check_hash = dates.id_meta_row_check_hash

        qualify
            row_number() over (
                partition by id_meta_row_check_hash order by dt_meta_exported
            ) = 1

    )

select *
from final
