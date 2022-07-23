
```today
select 
    format_date('%F',current_date()) as dt_today,
    extract(isoweek from current_date()) as val_current_iso_week
```
```daily_tracks

with
    daily_tracks as (
        select dt_track, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible

        from `dbt_backstop`.`sst_tracks`

        group by 1
    )

select 
    *, 
    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
from daily_tracks
order by 1 desc


```
```lw_tracks
select (sum(amt_tracks) / sum(amt_tracks_possible)) * 100 as val_track_success,
from ${daily_tracks}

where extract(isoweek from dt_track) = (select val_current_iso_week from ${today})


```
```pw_tracks
select (sum(amt_tracks) / sum(amt_tracks_possible)) * 100 as val_track_success
from ${daily_tracks}

where extract(isoweek from dt_track) = (select val_current_iso_week from ${today}) -1

```
```dimming_days
select extract(dayofweek from dt_track) as str_track_dow, val_track_success
from ${daily_tracks}
where
    extract(isoweek from dt_track) = (
        select val_current_iso_week from ${today}
    ) and val_track_success < val_track_target
order by 1

```
```dimming_habits
with
    habits as (
        select id_habit, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible
        from `dbt_backstop`.`sst_tracks`
        where
            extract(isoweek from dt_track) = (select val_current_iso_week from ${today})
        group by 1
    ),
    query as (
        select
            *,
            (amt_tracks / amt_tracks_possible) * 100 as val_track_success,
            80 as val_track_target
        from habits
    )

select *
from query
where val_track_success < val_track_target
order by 4

```

# Weekly Review - <Value data={today} column=val_current_iso_week/>
## Life OS
This week, my lights score was <Value data={lw_tracks} column=val_track_success/>% (<Value data={pw_tracks} column=val_track_success/>% PW).

*Dimming days:*

{#each dimming_days as day}

- {day.str_track_dow} - <Value data={day} column=val_track_success/>%  

{/each}

*Dimming habits:*

{#each dimming_habits as hab}

- {hab.id_habit} - <Value data={hab} column=val_track_success/>% 

{/each}