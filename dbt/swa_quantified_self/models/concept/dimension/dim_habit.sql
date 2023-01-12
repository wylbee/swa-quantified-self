with integration as (select * from {{ ref("int_habit") }}) select * from integration
