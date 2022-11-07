cube(`DimBudget`, {
  sql: `SELECT * FROM core.dim_budget`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    
  },
  
  measures: {
    count: {
      type: `count`,
      drillMembers: [idTillerBudget]
    }
  },
  
  dimensions: {
    isBudgetHiddenFromReporting: {
      sql: `is_budget_hidden_from_reporting`,
      type: `number`
    },
    
    valBudgetFiscalYear: {
      sql: `val_budget_fiscal_year`,
      type: `number`
    },
    
    isBudgetMonthlyLine: {
      sql: `is_budget_monthly_line`,
      type: `number`
    },
    
    keyBudget: {
      sql: `key_budget`,
      type: `string`,
      primaryKey: true
    },
    
    idTillerBudget: {
      sql: `id_tiller_budget`,
      type: `string`
    },
    
    catBudgetGroup: {
      sql: `cat_budget_group`,
      type: `string`
    },
    
    catBudgetType: {
      sql: `cat_budget_type`,
      type: `string`
    },
    
    valBudgetMonthly: {
      sql: `val_budget_monthly`,
      type: `string`
    },
    
    valBudgetYearly: {
      sql: `val_budget_yearly`,
      type: `string`
    }
  }
});
