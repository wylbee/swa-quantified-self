cube(`Stream`, {
  sql: `SELECT * FROM dbt_backstop.stream`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    
  },
  
  measures: {
    metricCount: {
      type: `count`,
      drillMembers: [habitId]
    },
    metricIsActivityComplete: {
      sql: `nest_activity_context.is_activity_complete`,
      type: `sum`
    },
    metricRatioActivityCompletion: {
      sql: `${metricIsActivityComplete} / ${metricCount} * 100.0`,
      type: `number`,
    }
  },
  
  dimensions: {
    keyActivity: {
      sql: `key_activity`,
      type: `string`
    },
    
    catActivityType: {
      sql: `cat_activity_type`,
      type: `string`
    },
    
    tmActivity: {
      sql: `tm_activity`,
      type: `time`
    },
    
    nestTrack: {
      sql: `nest_track`,
      type: `time`
    },
    
    nestHabitCv: {
      sql: `nest_habit_cv`,
      type: `time`
    },
    
    habitId: {
      sql: `nest_habit_cv.id_habit`,
      type: `string`
    },
    
    nestHabitScd: {
      sql: `nest_habit_scd`,
      type: `time`
    },
    
    tmNextActivity: {
      sql: `tm_next_activity`,
      type: `time`
    }
  }
});
