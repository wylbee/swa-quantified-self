
```tracks
with query as(
select 
    dt_track,
    sum(is_track) as tracks,
    count(*) as opps

    

from `qs-dev-352513`.`dbt_backstop`.`sst_tracks`

group by 1
)

select *, tracks/opps as merp from query
order by 1 desc

```

<Histogram 
    data={tracks} 
    x=merp
/>