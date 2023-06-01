with

    base as (select * from {{ ref("date_spine") }}),

    extracts as (
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
            end as is_calendar_month_first_day,
            case
                when last_day(date_day, month) = date_day then 1 else 0
            end as is_calendar_month_last_day,

            case
                when last_day(date_day, week) = date_day then 1 else 0
            end as is_calendar_week_last_day,
            case
                when last_day(date_day, isoweek) = date_day then 1 else 0
            end as is_calendar_isoweek_last_day,

            case when date_day = current_date then 1 else 0 end as is_calendar_today,
            case
                when date_day = current_date -1 then 1 else 0
            end as is_calendar_yesterday,
            case
                when extract(isoweek from date_day) = extract(isoweek from current_date)
                then 1
                else 0
            end as is_calendar_cisoweek
        from base
    ),

    final as (

        select
            *,

            case
                when key_calendar = date_sub(current_date, interval 6 week)
                then 1
                when is_calendar_today = 1
                then 1
                else 0
            end as is_calendar_6w_ago_or_today,
            case
                when key_calendar = date_sub(current_date, interval 12 week)
                then 1
                when is_calendar_today = 1
                then 1
                else 0
            end as is_calendar_12w_ago_or_today,
            case
                when key_calendar = date_sub(current_date, interval 52 week)
                then 1
                when is_calendar_today = 1
                then 1
                else 0
            end as is_calendar_52w_ago_or_today,
            case
                when is_calendar_yesterday = 1
                then 1
                when is_calendar_isoweek_last_day = 1
                then 1
                else 0
            end as is_calendar_isoweek_last_day_or_yesterday,
            case
                when is_calendar_yesterday = 1
                then 1
                when is_calendar_week_last_day = 1
                then 1
                else 0
            end as is_calendar_week_last_day_or_yesterday,

            case
                when is_calendar_today = 1
                then 1
                when is_calendar_month_last_day = 1
                then 1
                else 0
            end as is_calendar_month_last_day_or_today

        from extracts
    )

select *
from final
