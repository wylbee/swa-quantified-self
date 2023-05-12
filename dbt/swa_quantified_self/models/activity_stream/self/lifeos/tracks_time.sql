{{
    config(
        features=[
            "str_time_entry_description",
            "amt_time_entry_duration_minutes",
            "is_tag_meeting",
            "is_tag_deep_work",
            "is_tag_slope_learning",
            "is_tag_most_important_work",
        ]
    )
}}

with

    tracks as (select * from {{ ref("base_toggl__time_entries") }}),

    projects as (select * from {{ ref("base_toggl__projects") }}),

    joined as (

        select
            tracks.id_toggl_time_entry as activity_id,
            tracks.tm_time_entry_started as ts,
            'self' as customer,
            'tracks_time' as activity,
            to_json_string(
                struct(
                    tracks.id_toggl_project as key_project,
                    projects.id_toggl_client as key_client
                )
            ) as anonymous_customer_id,

            null as link,
            null as revenue_impact,

            tracks.str_time_entry_description,
            tracks.amt_time_entry_duration_minutes,
            tracks.is_tag_meeting,
            tracks.is_tag_deep_work,
            tracks.is_tag_slope_learning,
            tracks.is_tag_most_important_work


        from tracks

        left outer join projects on tracks.id_toggl_project = projects.id_toggl_project

    )

select *
from {{ activity_schema.make_activity("joined") }}
