# Weekly Review - {$page.params.str_activity_year_iso_week}
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
--    cast(extract(year from dt_track) as string)||'-W' || cast(extract(isoweek from dt_track) as string) as str_activity_year_iso_week,
--    (amt_tracks / amt_tracks_possible)*100 as val_track_success, 80 as val_track_target
--from daily_tracks
--order by 1 desc
select
    tm_activity,
    str_activity_year_iso_week,
    measure(metric_ratio_activity_completion) as metric_ratio_activity_completion,
    80 as val_habit_track_target

from Stream

group by 1,2

```
```weekly_tracks

--with
--    weekly_tracks as (
--        select             cast(extract(year from sst_tracks.dt_track) as string)||'-W' || cast(extract(isoweek from sst_tracks.dt_track) as string) as --str_activity_year_iso_week,extract(isoweek from sst_tracks.dt_track) as val_iso_week, sum(is_track) as amt_tracks, count(*) as amt_tracks_possible
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
select
    str_activity_year_iso_week,
    measure(metric_ratio_activity_completion) as metric_ratio_activity_completion,
    80 as val_habit_track_target

from Stream

group by 1

order by 1
```
```category_tracks
--with
--    category_tracks as (
--        select 
--            cast(extract(year from sst_tracks.dt_track) as string)||'-W' || cast(extract(isoweek from sst_tracks.dt_track) as string) as str_activity_year_iso_week, 
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

select
    str_activity_year_iso_week,
    cat_habit_grouping,
    measure(metric_ratio_activity_completion) as metric_ratio_activity_completion,
    80 as val_habit_track_target

from Stream

group by 1, 2

order by 1 

```
```dimming_days
select 
    str_activity_year_iso_week,
    str_activity_dow, 
    metric_ratio_activity_completion
from Stream
where metric_ratio_activity_completion < 80
order by 1

```
```dimming_categories
select 
    str_activity_year_iso_week,
    cat_habit_grouping, 
    metric_ratio_activity_completion
from ${category_tracks} a
where metric_ratio_activity_completion < val_habit_track_target
order by 1

```
```dimming_habits
--select
--    str_activity_year_iso_week,
--    id_habit,
--    str_habit_name,
--    metric_ratio_activity_completion as metric_ratio_activity_completion--,
--    --max(80) as val_habit_track_target
--
--from Stream
--
--where  metric_ratio_activity_completion <80
----group by 1, 2, 3
--order by 1


select
    str_activity_year_iso_week,
    id_habit,
    str_habit_name,
    metric_ratio_activity_completion

from Stream

--group by 1, 2, 3

where metric_ratio_activity_completion < 80

order by 3 desc


```
This week, my lights score was <Value data={weekly_tracks.filter(d => d.str_activity_year_iso_week === $page.params.str_activity_year_iso_week)} column=metric_ratio_activity_completion/>%.

<BarChart 
    title='Lights'
    data={weekly_tracks.filter(d => d.str_activity_year_iso_week <= $page.params.str_activity_year_iso_week)}
    x=str_activity_year_iso_week
    y=metric_ratio_activity_completion
    sort= false
/>

For review, the following categories were in a dimmed state this week:

*Dimming categories*

{#each dimming_categories.filter(d => d.str_activity_year_iso_week === $page.params.str_activity_year_iso_week) as dc}

- **{dc.cat_habit_grouping}** - <Value data={dc} column=metric_ratio_activity_completion/>%  

{/each}

*Dimming days*

{#each dimming_days.filter(d => d.str_activity_year_iso_week === $page.params.str_activity_year_iso_week) as dd}

- **{dd.str_activity_dow}** - <Value data={dd} column=metric_ratio_activity_completion/>%  

{/each}

*Dimming habits*

{#each dimming_habits.filter(d => d.str_activity_year_iso_week === $page.params.str_activity_year_iso_week) as hab}

- **{hab.str_habit_name}** - <Value data={hab} column=metric_ratio_activity_completion/>% 

{/each}