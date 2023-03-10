with

    base as (select * from {{ ref("date_spine") }}),

    final as (
        select
            date_day as key_calendar,
            extract(year from date_day) as val_calendar_year,
            extract(quarter from date_day) as val_calendar_quarter,
            extract(month from date_day) as val_calendar_month,
            extract(week from date_day) as val_calendar_week,
            extract(isoweek from date_day) as val_calendar_isoweek,
            extract(dayofweek from date_day) as val_calendar_dow,
            case
                when extract(day from date_day) = 1 then 1 else 0
            end as is_calendar_month_first_day
        from base
    )

select *
from final
