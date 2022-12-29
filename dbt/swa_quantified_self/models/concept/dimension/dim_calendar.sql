with
    spine as (
        {{
            dbt_utils.date_spine(
                datepart="day",
                start_date="cast('2022-01-01' as date)",
                end_date="date_add(current_date(), interval 2 year)",
            )
        }}
    ),

    renamed as (select cast(date_day as date) as key_calendar from spine),

    final as (

        select
            key_calendar,
            case
                when extract(day from key_calendar) = 1 then 1 else 0
            end as is_calendar_month_first_day

        from renamed
    )

select *
from final
