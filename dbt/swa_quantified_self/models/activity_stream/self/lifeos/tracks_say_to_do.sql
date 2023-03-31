{{
    config(
        features=[
            "cat_area_group",
            "n_say_wc",
            "n_do_wc",
            "n_say_nwc",
            "n_do_nwc",
            "n_say",
            "n_do",
            "wtd_say_to_do_wc",
            "wtd_say_to_do",
        ]
    )
}}

with

    tracks as (select * from {{ ref("base_gsheet__say_to_do_weekly") }}),

    joined as (

        select
            tracks.id_std as activity_id,
            cast(tracks.dt_track as timestamp) as ts,
            'self' as customer,
            'tracks_say_to_do' as activity,
            to_json_string(struct()) as anonymous_customer_id,

            '{{ var("str_say_to_do_url") }}' as link,
            null as revenue_impact,

            tracks.cat_area_group,
            tracks.n_say_wc,
            tracks.n_do_wc,
            tracks.n_say_nwc,
            tracks.n_do_nwc,
            tracks.n_say,
            tracks.n_do,
            tracks.wtd_say_to_do_wc,
            tracks.wtd_say_to_do

        from tracks

    )

select *
from {{ activity_schema.make_activity("joined") }}
