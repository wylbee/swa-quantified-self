{{ config(features=["amt_balance_lv"]) }}

with
    pde as (select * from {{ ref("updates_balance") }}),
    calendar as (select * from {{ ref("date_spine") }}),

    de as (

        select
            *,
            {{ acid_str("key_finaccount") }},
            activity_id as key_event,
            {{ fj_amt("amt_balance") }}

        from pde
    ),

    start_end as (

        select
            key_finaccount,
            cast(min(ts) as date) as dt_balance_min,
            max(current_date()) as dt_balance_max

        from de

        group by 1

    ),

    grain as (
        select calendar.date_day as key_calendar, start_end.key_finaccount
        from calendar
        inner join
            start_end
            on calendar.date_day >= start_end.dt_balance_min
            and calendar.date_day <= start_end.dt_balance_max
    ),

    de_latest_daily as (

        select *
        from de

        qualify
            row_number() over (
                partition by
                    key_finaccount,
                    extract(year from ts),
                    extract(month from ts),
                    extract(day from ts)
                order by ts desc
            )
            = 1

    ),

    at_grain as (

        select
            grain.key_calendar,
            grain.key_finaccount,
            de_latest_daily.key_event,
            de_latest_daily.amt_balance

        from grain

        left outer join
            de_latest_daily
            on grain.key_calendar = date(de_latest_daily.ts)
            and grain.key_finaccount = de_latest_daily.key_finaccount

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
            concat('lv | ', windowed.key_event) as activity_id,
            cast(windowed.key_calendar as timestamp) as ts,
            'self' as customer,
            'updates_eod_balance' as activity,
            de.anonymous_customer_id,

            null as revenue_impact,
            '{{ var("str_tiller_url") }}' as link,
            windowed.amt_balance_lv

        from windowed

        left outer join de on windowed.key_event = de.key_event

    )

select *
from {{ activity_schema.make_activity("joined") }}
