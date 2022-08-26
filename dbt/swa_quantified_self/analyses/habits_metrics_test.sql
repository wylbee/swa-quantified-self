select * 
from {{ metrics.calculate(
    [metric('metric_n_track_habit_success'), metric('metric_n_track_habit_possible'), metric('metric_val_track_habit_success_percentage')],
    grain='day',
    dimensions=['cat_habit_grouping'],
    secondary_calculations=[
        metrics.period_to_date(aggregate="sum", period="quarter", alias="val_track_habit_qtd"),
    ],
    start_date='2022-07-01',
    end_date='2022-07-31'
)}}