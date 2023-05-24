with

    stream as (select * from {{ ref("self_stream") }}),

    final as (

        select {{ acid_str("key_client") }}, {{ fj_str("str_client_name") }}

        from stream

        where activity = 'creates_client'

    )

select *
from final
