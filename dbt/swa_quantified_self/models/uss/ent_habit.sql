with

    habits as (select * from {{ ref("base_loop_habits__habits") }}),

    final as (select id_habit as key_habit, * from habits)

select *
from final
