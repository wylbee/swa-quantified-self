with
    de as (select * from {{ ref("de_assesses_balance") }}),
    calendar as (select * from {{ ref("int_calendar") }}),

    start_end as (

        select
            json_value(json_event_entities.`key_finaccount`) as key_finaccount,
            cast(min(tm_event) as date) as dt_balance_min,
            max(current_date()) as dt_balance_max

        from de

        group by 1

    ),

    grain as (
        select calendar.key_calendar, start_end.key_finaccount
        from calendar
        inner join
            start_end
            on calendar.key_calendar >= start_end.dt_balance_min
            and calendar.key_calendar <= start_end.dt_balance_max
    ),

    de_latest_daily as (

        select *
        from de

        qualify
            row_number() over (
                partition by
                    json_value(json_event_entities.`key_finaccount`),
                    extract(year from tm_event),
                    extract(month from tm_event),
                    extract(day from tm_event)
                order by tm_event desc
            )
            = 1

    ),

    at_grain as (

        select
            grain.key_calendar,
            grain.key_finaccount,
            de_latest_daily.key_event,
            cast(
                json_value(de_latest_daily.json_event_features.`amt_balance`) as numeric
            ) as amt_balance

        from grain

        left outer join
            de_latest_daily
            on grain.key_calendar = date(de_latest_daily.tm_event)
            and grain.key_finaccount
            = json_value(de_latest_daily.json_event_entities.`key_finaccount`)

    ),

    windowed as (

        select
            * except (key_event),

            last_value(key_event ignore nulls) over (
                partition by key_finaccount
                order by key_calendar
                rows between unbounded preceding and current row
            ) as key_event,

            last_value(amt_balance ignore nulls) over (
                partition by key_finaccount
                order by key_calendar
                rows between unbounded preceding and current row
            ) as amt_balance_lv

        from at_grain
    ),

    joined as (

        select
            cast(windowed.key_calendar as timestamp) as tm_event,
            'System measures EOD Finaccount' as cat_event,
            de.json_event_entities,
            to_json(struct(windowed.amt_balance_lv)) as json_event_features,
            de.json_event_source

        from windowed

        left outer join de on windowed.key_event = de.key_event

    ),

    final as (
        select
            {{
                dbt_utils.surrogate_key(
                    ["json_value(json_event_source.id_tiller_balance)", "tm_event"]
                )
            }} as key_event,
            *,
            row_number() over (
                partition by json_value(json_event_entities.key_finaccount)
                order by tm_event
            ) as n_event_occurrence,

            lead(tm_event) over (
                partition by json_value(json_event_entities.key_finaccount)
                order by tm_event
            ) as tm_next_event
        from joined

    )

select *
from final
