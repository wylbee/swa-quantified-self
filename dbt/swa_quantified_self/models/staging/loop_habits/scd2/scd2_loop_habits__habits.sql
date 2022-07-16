{{ config(
    materialized = 'incremental',
    unique_key = 'id_meta_row_check_hash',
    merge_update_columns = ['dt_valid_to']
) }}


with all_or_new as (

    select * from {{ ref('corz_loop_habits__habits') }}

    {% if is_incremental() %}
    
        -- get the latest day of data from when this model was last run.
        -- always reprocess that day and the day before (just to be safe)
        -- plus anything newer, of course
    
        where dt_meta_exported >= datetime_sub(
            cast( (select max(dt_meta_last_change_event) from {{ this }}) as datetime),
        interval 1 day
        )
    
    {% endif %}

),

dates as (

    select
        id_habit,
        id_meta_row_check_hash,
        dt_meta_last_change_event,
        lead(dt_meta_last_change_event) over (partition by id_habit order by dt_meta_last_change_event) as dt_meta_next_change_event

    from all_or_new

    group by 1,2,3

),

windowed as (

    select 
        all_or_new.*,
        dates.dt_meta_last_change_event as dt_valid_from,
        
        -- valid_to should be null if this id_habit_scd appears in the most recent day of data
        -- (i.e. the record is still valid)
        dt_meta_next_change_event as dt_valid_to
        
    from all_or_new
    --{{ dbt_utils.group_by(n=13) }}
    left outer join dates 
        on all_or_new.id_meta_row_check_hash = dates.id_meta_row_check_hash

)

select * from windowed
-- deduplicate: only take the latest day of data for each id_habit_scd
qualify row_number() over (partition by id_meta_row_check_hash order by dt_meta_exported) = 1
