with

    stream as (select * from {{ ref("self_stream") }}),

    final as (

        select
            {{ acid_str("key_project") }},
            {{ fj_str("str_project_name") }},
            {{ fj_n("is_project_active") }}

        from stream

        where activity = 'creates_project'
    )

select *
from final
