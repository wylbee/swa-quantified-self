{{
    config(
        features=[
            "str_project_name",
            "is_project_active",
        ]
    )
}}

with

    projects as (select * from {{ ref("base_toggl__projects") }}),

    joined as (

        select
            id_toggl_project as activity_id,
            tm_project_created as ts,
            'self' as customer,
            'creates_project' as activity,
            to_json_string(
                struct(id_toggl_project as key_project, id_toggl_client as key_client)
            ) as anonymous_customer_id,

            null as link,
            null as revenue_impact,

            str_project_name,
            is_project_active

        from projects

    )

select *
from {{ activity_schema.make_activity("joined") }}
