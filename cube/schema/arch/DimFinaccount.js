cube(`DimFinaccount`, {
  sql: `SELECT * FROM core.dim_finaccount`,
  
  preAggregations: {
    // Pre-Aggregations definitions go here
    // Learn more here: https://cube.dev/docs/caching/pre-aggregations/getting-started  
  },
  
  joins: {
    
  },
  
  measures: {
    count: {
      type: `count`,
      drillMembers: [idTillerFinaccount, strFinaccountName]
    }
  },
  
  dimensions: {
    isFinaccountSavings: {
      sql: `is_finaccount_savings`,
      type: `number`
    },
    
    keyFinaccount: {
      sql: `key_finaccount`,
      type: `string`,
      primaryKey: true
    },
    
    idTillerFinaccount: {
      sql: `id_tiller_finaccount`,
      type: `string`
    },
    
    strFinaccountName: {
      sql: `str_finaccount_name`,
      type: `string`
    },
    
    catFinaccountClass: {
      sql: `cat_finaccount_class`,
      type: `string`
    },
    
    catFinaccountGroup: {
      sql: `cat_finaccount_group`,
      type: `string`
    },
    
    catFinaccountInstitution: {
      sql: `cat_finaccount_institution`,
      type: `string`
    },
    
    catFinaccountInstitutionType: {
      sql: `cat_finaccount_institution_type`,
      type: `string`
    }
  }
});
