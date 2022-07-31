select * 
from {{ metrics.calculate(
    metric('metric_n_track_habit_success'),
    grain='day',
    dimensions=['id_habit'],
    start_date='2022-07-01',
    end_date='2022-07-31'
)}}