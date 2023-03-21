with

    habits as (select * from {{ ref("base_loop_habits__habits") }}),

    final as (
        select
            id_habit as key_habit,
            *,
            case
                when str_habit_description = '#PENTATHALON' then 1 else 0
            end as is_habit_pentathalon
        from habits
    )

select *
from final
