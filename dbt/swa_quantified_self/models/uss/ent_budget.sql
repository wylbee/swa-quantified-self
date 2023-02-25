with

    base as (select * from {{ ref("base_tiller__categories") }}),

    final as (select id_tiller_budget as key_budget, * from base)

select *
from final
