with
    source as (select * from {{ source("google_drive", "say_to_do_weekly") }}),

    renamed as (

        select
            {{
                dbt_utils.surrogate_key(
                    ["val_calendar_week", "val_calendar_year", "cat_area_group"]
                )
            }} as id_std,
            date_add(
                date_trunc(
                    parse_date(
                        '%Y%m%d',
                        concat(
                            substr(concat(val_calendar_year, val_calendar_week), 1, 4),
                            '0104'
                        )
                    ),
                    isoyear
                ),
                interval cast(
                    substr(concat(val_calendar_year, val_calendar_week), -2) as int64
                ) -1 week
            ) as dt_track,
            val_calendar_year,
            val_calendar_week,
            cat_area_group,
            n_say_wc,
            n_do_wc,
            n_say_nwc,
            n_do_nwc,
            n_say,
            n_do,
            wtd_say_to_do_wc,
            wtd_say_to_do

        from source

    )

select *
from renamed
