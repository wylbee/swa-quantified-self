# Weekly Review - {$page.params.str_year_iso_week}
## Life OS
```daily_tracks

--with
--    daily_tracks as (
--        select dt_track, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible
--
--        from `dbt_backstop`.`sst_tracks`
--
--        group by 1
--    )
--
--select 
--    *,
--    cast(extract(year from dt_track) as string)||'-W' || cast(extract(isoweek from dt_track) as string) as str_year_iso_week,
--    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
--from daily_tracks
--order by 1 desc
select
    tm_activity,
    str_year_iso_week,
    measure(metric_ratio_activity_completion) as metric_ratio_activity_completion,
    80 as val_habit_track_target

from Stream

group by 1,2

```
```weekly_tracks

--with
--    weekly_tracks as (
--        select             cast(extract(year from sst_tracks.dt_track) as string)||'-W' || cast(extract(isoweek from sst_tracks.dt_track) as string) as --str_year_iso_week,extract(isoweek from sst_tracks.dt_track) as val_iso_week, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible
--
--        from `dbt_backstop`.`sst_tracks`
--
--        group by 1,2
--    )
--
--select 
--    *,
--    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
--from weekly_tracks
--order by val_iso_week


```
```category_tracks
--with
--    category_tracks as (
--        select 
--            cast(extract(year from sst_tracks.dt_track) as string)||'-W' || cast(extract(isoweek from sst_tracks.dt_track) as string) as str_year_iso_week, 
--            sst_habits.cat_habit_grouping,
--            
--            sum(sst_tracks.is_track) as amt_tracks, count(sst_tracks.dt_track) as amt_tracks_possible
--
--        from `dbt_backstop`.`sst_tracks`
--
--        left outer join `dbt_backstop`.`sst_habits`
--            on sst_tracks.id_habit = sst_habits.id_habit and sst_habits.dt_meta_valid_to is null
--
--        group by 1,2
--    )
--
--select 
--    *,
--
--    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
--from category_tracks 
--order by 1 desc

```
```dimming_days
select 
    str_year_iso_week,
    tm_activity as str_track_dow, 
    metric_ratio_activity_completion
from ${daily_tracks} a
where metric_ratio_activity_completion < val_habit_track_target
order by 1

```
```dimming_categories
--select 
--    str_year_iso_week,
--    cat_habit_grouping, 
--    val_track_success
--from ${category_tracks}
--where val_track_success < val_track_target
--order by 1

```
```dimming_habits
--with query as (
--select 
--    cast(extract(year from dt_track) as string)||'-W' || cast(extract(isoweek from dt_track) as string) as str_year_iso_week,
--    id_habit,
--sum(is_track) as amt_tracks, count(*) as amt_tracks_possible
--
--from `dbt_backstop`.`sst_tracks`
--
--group by 1,2
--
--),
--
--next_query as (
--
--select 
--    query.*,
--        (query.amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target,
--    sst_habits.str_habit_name 
--
--from query
--
--left outer join `dbt_backstop`.`sst_habits`
--    on query.id_habit = sst_habits.id_habit and sst_habits.dt_meta_valid_to is null
--
--)
--
--select * from next_query
--where val_track_success < val_track_target
--
--order by val_track_success
```
This week, my lights score was <Value data={weekly_tracks.filter(d => d.str_year_iso_week === $page.params.str_year_iso_week)} column=val_track_success/>%.

<BarChart 
    title='Lights'
    data={weekly_tracks.filter(d => d.str_year_iso_week <= $page.params.str_year_iso_week)}
    x=str_year_iso_week
    y=val_track_success
    sort= false
/>

For review, the following categories were in a dimmed state this week:

*Dimming categories*

{#each dimming_categories.filter(d => d.str_year_iso_week === $page.params.str_year_iso_week) as dc}

- **{dc.cat_habit_grouping}** - <Value data={dc} column=val_track_success/>%  

{/each}

*Dimming days*

{#each dimming_days.filter(d => d.str_year_iso_week === $page.params.str_year_iso_week) as dd}

- **{dd.str_track_dow}** - <Value data={dd} column=val_track_success/>%  

{/each}

*Dimming habits*

{#each dimming_habits.filter(d => d.str_year_iso_week === $page.params.str_year_iso_week) as hab}

- **{hab.str_habit_name}** - <Value data={hab} column=val_track_success/>% 

{/each}