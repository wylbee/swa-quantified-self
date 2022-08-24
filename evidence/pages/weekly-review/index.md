# Weekly Reviews

```eligible_weeks

select 
    str_activity_year_iso_week

from Stream

order by 1 desc
```

{#each eligible_weeks as ew}
    
[{ew.str_activity_year_iso_week}](/weekly-review/{ew.str_activity_year_iso_week})

{/each}