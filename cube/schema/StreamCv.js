cube(`StreamCv`, {
  sql: `SELECT * FROM dbt_backstop.stream_cv`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    
  },
  
  measures: {
    count: {
      type: `count`,
      drillMembers: [idTrack, idHabit, idMetaTracksRowCheckHash, idMetaScoresRowCheckHash, strHabitName, strMetaFileName, idMetaHabitsRowCheckHash, dtMetaValidFrom, dtMetaValidTo]
    },
    metric_is_track: {
      sql: `is_activity_complete`,
      type: `sum`,
    },
    metric_ratio_track_success: {
      sql: `${metric_is_track} / ${count} * 100.0`,
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
    
    keyTrack: {
      sql: `key_track`,
      type: `string`
    },
    
    idTrack: {
      sql: `id_track`,
      type: `string`
    },
    
    idHabit: {
      sql: `id_habit`,
      type: `string`
    },
    
    valTrackScore: {
      sql: `val_track_score`,
      type: `string`
    },
    
    idMetaTracksRowCheckHash: {
      sql: `id_meta_tracks_row_check_hash`,
      type: `string`
    },
    
    idMetaScoresRowCheckHash: {
      sql: `id_meta_scores_row_check_hash`,
      type: `string`
    },
    
    keyHabit: {
      sql: `key_habit`,
      type: `string`
    },
    
    strHabitName: {
      sql: `str_habit_name`,
      type: `string`
    },
    
    strHabitPrompt: {
      sql: `str_habit_prompt`,
      type: `string`
    },
    
    strHabitDescription: {
      sql: `str_habit_description`,
      type: `string`
    },
    
    strHabitColorHex: {
      sql: `str_habit_color_hex`,
      type: `string`
    },
    
    strMetaFileName: {
      sql: `str_meta_file_name`,
      type: `string`
    },
    
    catHabitGrouping: {
      sql: `cat_habit_grouping`,
      type: `string`
    },
    
    idMetaHabitsRowCheckHash: {
      sql: `id_meta_habits_row_check_hash`,
      type: `string`
    },
    
    tmActivity: {
      sql: `tm_activity`,
      type: `time`
    },
    
    tmNextActivity: {
      sql: `tm_next_activity`,
      type: `time`
    },
    
    dtTrack: {
      sql: `dt_track`,
      type: `time`
    },
    
    dtMetaExported: {
      sql: `dt_meta_exported`,
      type: `time`
    },
    
    dtMetaLastChangeEvent: {
      sql: `dt_meta_last_change_event`,
      type: `time`
    },
    
    dtMetaValidFrom: {
      sql: `dt_meta_valid_from`,
      type: `time`
    },
    
    dtMetaValidTo: {
      sql: `dt_meta_valid_to`,
      type: `time`
    }
  }
});
