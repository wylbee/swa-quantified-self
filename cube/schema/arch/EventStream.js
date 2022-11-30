cube(`EventStream`, {
  sql: `SELECT * FROM core.event_stream`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    DimFinaccount: {
      sql: `${keyFinaccount} = ${DimFinaccount}.key_finaccount`,
      relationship: `belongsTo`
    },
    
    DimBudget: {
      sql: `${keyBudget} = ${DimBudget}.key_budget`,
      relationship: `belongsTo`
    }
  },
  
  measures: {
    count: {
      type: `count`,
      drillMembers: []
    },

    amt_income_base: {
      sql: `cast(json_value(${CUBE}.json_event_features.amt_income) as numeric)`,
      type: `number`,
      format: `currency`
    },

    amt_income_sum: {
      sql: `${amt_income_base}`,
      type: `sum`,
      format: `currency`
    },

    amt_income_cumulative: {
      sql: `${amt_income_base}`,
      type: `runningTotal`,
      format: `currency`
    },

    amt_invested_base: {
      sql: `cast(json_value(${CUBE}.json_event_features.amt_invested) as numeric)`,
      type: `number`,
      format: `currency`
    },

    amt_invested_sum: {
      sql: `${amt_invested_base}`,
      type: `sum`,
      format: `currency`
    },

    amt_invested_cumulative: {
      sql: `${amt_invested_base}`,
      type: `runningTotal`,
      format: `currency`
    },

    mtc_savings_rate: {
      sql: `(${amt_invested_sum}/${amt_income_sum})*100`,
      type: `number`,
      format: `percent`
    },

    mtc_savings_rate_cumulative: {
      sql: `(${amt_invested_cumulative}/${amt_income_cumulative})*100`,
      type: `number`,
      format: `percent`
    }
  },

  dimensions: {
    nEventOccurrence: {
      sql: `${CUBE}.n_event_occurrence`,
      type: `number`
    },
    
    keyEvent: {
      sql: `${CUBE}.key_event`,
      type: `string`,
      primaryKey: true
    },

    keyFinaccount: {
      sql: `json_value(${CUBE}.json_event_entities.key_finaccount)`,
      type: `string`
    },

    keyBudget: {
      sql: `json_value(${CUBE}.json_event_entities.key_budget)`,
      type: `string`
    },
    
    catEvent: {
      sql: `${CUBE}.cat_event`,
      type: `string`
    },
    
    jsonEventEntities: {
      sql: `${CUBE}.json_event_entities`,
      type: `string`
    },
    
    jsonEventFeatures: {
      sql: `${CUBE}.json_event_features`,
      type: `string`
    },
    
    jsonEventSource: {
      sql: `${CUBE}.json_event_source`,
      type: `string`
    },
    
    tmEvent: {
      sql: `${CUBE}.tm_event`,
      type: `time`
    },
    
    tmNextEvent: {
      sql: `${CUBE}.tm_next_event`,
      type: `time`
    }
  }
});
