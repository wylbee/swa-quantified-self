with
    habits as (select * from {{ ref("base_loop_habits__habits") }}),

    final as (

        select
            id_meta_row_check_hash as key_habit,
            * except (id_meta_row_check_hash),
            id_meta_row_check_hash as id_meta_habits_row_check_hash

        from habits

    )

select *
from final
