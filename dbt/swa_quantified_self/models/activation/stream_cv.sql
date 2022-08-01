with 

stream as (
    select * except(nest_activity_context,nest_habit_cv,nest_habit_scd,nest_track), nest_activity_context.* ,nest_track.*, nest_habit_cv.* except (id_habit) from {{ref('stream')}}
)

select * from stream
