# Weekly Reviews

```eligible_weeks

select distinct
    cast(extract(year from dt_track) as string)||'-W' || cast(extract(isoweek from dt_track) as string) as str_year_iso_week

from `dbt_backstop`.`sst_tracks`

order by 1 desc
```

{#each eligible_weeks as ew}
    
[{ew.str_year_iso_week}](/weekly-review/{ew.str_year_iso_week})

{/each}