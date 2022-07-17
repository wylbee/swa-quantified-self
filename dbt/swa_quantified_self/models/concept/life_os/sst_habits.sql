with

habits as (

    select * from {{ ref('scd2_loop_habits__habits') }}
)

select * from habits