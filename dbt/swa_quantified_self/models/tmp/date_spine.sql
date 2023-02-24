with
    spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2022-01-01' as date)",
                end_date="date_add(current_date(), interval 2 year)",
            )
        }}
    )
select *
from spine
