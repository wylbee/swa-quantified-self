with

    tracks as (select * from {{ ref("base_gsheet__say_to_do_weekly") }}),

    calendar as (select * from {{ ref("int_calendar") }} where val_calendar_dow = 1),

    joined as (

        select
            cast(calendar.key_calendar as timestamp) as tm_event,
            case
                when tracks.cat_area_group = 'Professional'
                then 'Person tracks Professional Say-to-Do'
                when tracks.cat_area_group = 'Personal'
                then 'Person tracks Personal Say-to-Do'
            end as cat_event,

            '{{ var("str_say_to_do_url") }}' as str_source_url,
            tracks.id_std as id_source,
            to_json(struct(tracks.cat_area_group)) as json_event_features,

            tracks.n_say_wc,
            tracks.n_do_wc,
            tracks.n_say_nwc,
            tracks.n_do_nwc,
            tracks.n_say,
            tracks.n_do

        from tracks

        left outer join
            calendar
            on tracks.val_calendar_year = calendar.val_calendar_year
            and tracks.val_calendar_week = calendar.val_calendar_isoweek


    ),

    {{
        generate_final_event_cte(
            prev_cte_name="joined",
            surrogate_key_columns=["id_source"],
            responsible_subject_column="cat_event",
        )
    }}
