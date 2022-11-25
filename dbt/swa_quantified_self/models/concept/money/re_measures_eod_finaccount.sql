with
    de as (select * from {{ ref("de_assesses_balance") }}),
    calendar as (select * from {{ ref("int_calendar") }}),

    start_end as (

        select
            key_finaccount,
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
                    key_finaccount,
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
            de_latest_daily.amt_balance

        from grain

        left outer join
            de_latest_daily
            on grain.key_calendar = date(de_latest_daily.tm_event)
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
            cast(windowed.key_calendar as timestamp) as tm_event,
            'System measures EOD Finaccount' as cat_event,
            de.key_finaccount,
            windowed.amt_balance_lv,
            de.id_source,
            de.str_source_url,
            de.json_event_features

        from windowed

        left outer join de on windowed.key_event = de.key_event

    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source", "tm_event"],
            responsible_subject_column="key_finaccount",
        )
    }}
