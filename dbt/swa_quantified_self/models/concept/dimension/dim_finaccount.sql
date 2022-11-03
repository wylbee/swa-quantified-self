with integration as (select * from {{ ref("int_finaccount") }})

select *
from integration
