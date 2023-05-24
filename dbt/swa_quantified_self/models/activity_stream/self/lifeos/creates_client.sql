{{
    config(
        features=[
            "str_client_name",
        ]
    )
}}

with

    clients as (select * from {{ ref("base_toggl__clients") }}),

    joined as (

        select
            id_toggl_client as activity_id,
            tm_client_created as ts,
            'self' as customer,
            'creates_client' as activity,
            to_json_string(
                struct(id_toggl_client as key_client)
            ) as anonymous_customer_id,

            null as link,
            null as revenue_impact,

            str_client_name

        from clients

    )

select *
from {{ activity_schema.make_activity("joined") }}
