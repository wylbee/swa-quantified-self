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

    renamed as (
        select
            date_day as key_calendar,
            extract(year from date_day) as val_calendar_year,
            extract(month from date_day) as val_calendar_month,
            extract(day from date_day) as val_calendar_day
        from spine

    )

select *
from renamed
