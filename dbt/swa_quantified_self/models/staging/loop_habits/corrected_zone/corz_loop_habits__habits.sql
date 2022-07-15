with source as (

    select *, _FILE_NAME as str_gcs_file_name from {{ source('gcs_raw', 'habits') }} --where dt_processed != '2022-07-14'

),

parsed as (

    select
        *,
        substr(Name, (strpos(Name, '[') + 1), (LENGTH(Name) - STRPOS(Name, '[')-1)) as id_habit

    from source

),

final as (

    select
        * except (id_habit),
        case
            when id_habit = 'L0H24' then 'LH024'
            when id_habit = 'LH24' then 'LH024'
            when id_habit = 'LH23' then 'LH023'
            else id_habit
        end as id_habit
    
    from parsed

)

select * from final order by id_habit
