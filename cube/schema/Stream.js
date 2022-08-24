cube(`Stream`, {
  sql: `SELECT * FROM dbt_backstop.stream`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    
  },
  
  measures: {
    metric_count: {
      type: `count`,
      drillMembers: [id_habit]
    },
    metric_is_activity_complete: {
      sql: `nest_activity_context.is_activity_complete`,
      type: `sum`
    },
    metric_ratio_activity_completion: {
      sql: `${metric_is_activity_complete} / ${metric_count} * 100.0`,
      type: `number`,
    }
  },
  
  dimensions: {
    key_activity: {
      sql: `key_activity`,
      type: `string`
    },
    
    cat_activity_type: {
      sql: `cat_activity_type`,
      type: `string`
    },
    
    tm_activity: {
      sql: `tm_activity`,
      type: `time`
    },

    str_activity_year_iso_week: {
      sql: `cast(extract(year from ${tm_activity}) as string)||'-W' || cast(extract(isoweek from ${tm_activity}) as string) `,
      type: `string`
    },

    str_activity_dow: {
      sql: `format_date('%A',${tm_activity}) `,
      type: `string`
    },
    
    id_habit: {
      sql: `nest_habit_cv.id_habit`,
      type: `string`
    },

    str_habit_name: {
      sql: `nest_habit_cv.str_habit_name`,
      type: `string`
    },

    cat_habit_grouping: {
      sql: `nest_habit_cv.cat_habit_grouping`,
      type: `string`
    },
    
    tmNextActivity: {
      sql: `tm_next_activity`,
      type: `time`
    }
  }
});
