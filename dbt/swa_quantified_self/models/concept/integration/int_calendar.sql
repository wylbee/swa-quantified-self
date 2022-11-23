with
    spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2021-01-01' as date)",
                end_date="date_add(current_date(), interval 1 day)",
            )
        }}
    ),

    renamed as (select date_day as key_calendar from spine)

select *
from renamed
