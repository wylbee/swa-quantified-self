with integration as (select * from {{ ref("int_calendar") }}) select * from integration
