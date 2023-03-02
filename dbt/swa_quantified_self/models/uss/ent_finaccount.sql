with

    base as (select * from {{ ref("base_tiller__accounts") }}),

    final as (select id_tiller_finaccount as key_finaccount, * from base)

select *
from final
