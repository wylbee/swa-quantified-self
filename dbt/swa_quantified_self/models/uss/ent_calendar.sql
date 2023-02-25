with

    base as (select * from {{ ref("date_spine") }}),

    final as (select date_day as key_calendar from base)

select *
from final
