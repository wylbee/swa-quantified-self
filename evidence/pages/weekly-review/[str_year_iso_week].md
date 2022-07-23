# {$page.params.str_year_iso_week}

```daily_tracks

with
    daily_tracks as (
        select dt_track, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible

        from `dbt_backstop`.`sst_tracks`

        group by 1
    )

select 
    *,
    cast(extract(year from dt_track) as string)||'-' || cast(extract(isoweek from dt_track) as string) as str_year_iso_week,
    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
from daily_tracks
order by 1 desc


```

<BarChart 
    title='Lights'
    data={daily_tracks.filter(d => d.str_year_iso_week === $page.params.str_year_iso_week)}
    x=dt_track
    y=val_track_success
/>