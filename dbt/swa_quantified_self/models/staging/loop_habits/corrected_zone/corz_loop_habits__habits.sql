with source as (

    select *, _FILE_NAME as str_gcs_file_name from {{ source('gcs_raw', 'habits') }} --where dt_processed != '2022-07-14'

),

parsed as (

    select
        *,
        substr(Name, (strpos(Name, '[') + 1), (LENGTH(Name) - STRPOS(Name, '[')-1)) as id_habit

    from source

),

cleaned as (

    select
        case
            when id_habit = 'L0H24' then 'LH024'
            when id_habit = 'LH24' then 'LH024'
            when id_habit = 'LH23' then 'LH023'
            else id_habit
        end as id_habit,

         {{ dbt_utils.surrogate_key([
            'Position', 
            'Name',
            'Question',
            'Description',
            'NumRepetitions',
            '`Interval`',
            'Color',
            'id_habit',
        ]) }} as id_meta_row_check_hash,       

        Position as val_habit_position,
        Name as str_habit_name,
        Question as str_habit_prompt,
        Description as str_habit_description,
        NumRepetitions as val_habit_target,
        `Interval` as val_habit_interval,
        Color as str_habit_color_hex,
        dt_processed as dt_meta_exported,
        str_gcs_file_name as str_meta_file_name
    
    from parsed

),

change_event as (

    select
        *,
        case 
            when coalesce(lag(id_meta_row_check_hash) over (
            partition by id_habit
            order by dt_meta_exported
        ), 'new_row') != id_meta_row_check_hash then dt_meta_exported
        end as dt_meta_change_event
        
    from cleaned

),

final as (

    select
        * except (dt_meta_change_event),
        min(dt_meta_change_event) over (partition by id_meta_row_check_hash) as dt_meta_last_change_event
    from change_event

)


select * from final order by id_habit, dt_meta_exported
