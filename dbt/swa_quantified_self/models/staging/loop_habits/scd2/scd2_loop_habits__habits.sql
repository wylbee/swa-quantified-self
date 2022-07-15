{{ config(
    materialized = 'table'
) }}

with corrected as (

    select * from {{ ref('corz_loop_habits__habits') }}


),

row_hash as (

    select
        *,
        {{ dbt_utils.surrogate_key([
            'position', 
            'Name',
            'Question',
            'Description',
            'NumRepetitions',
            '`Interval`',
            'Color',
            'id_habit',
        ]) }} as id_row_check_hash

    from corrected

    qualify coalesce(lag(id_row_check_hash) over (
            partition by id_habit
            order by dt_processed
        ), 'new_row') != id_row_check_hash

),

final as (

    select *,
            {{ dbt_utils.surrogate_key(['id_habit', 'dt_processed']) }} as id_scd,
        case
            when dt_processed = '2022-06-12' then '2022-01-01'
            else dt_processed
        end as dt_valid_from,
        lead(dt_processed) over (partition by id_habit order by dt_processed) as dt_valid_to
        
    from row_hash

)


select * from final