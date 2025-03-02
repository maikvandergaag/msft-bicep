using './budget-alert.bicep'

param name = 'Bicep Budget Alert 2'
param amount = 1000
param timeGrain = 'Monthly'
param notifications = {
  budgetone: {
    enabled: true
    operator: 'GreaterThan'
    threshold: 80
    contactEmails: [
      'maik@familie-vandergaag.nl'
    ]
    thresholdType: 'Actual'
  }
  budgettwo: {
    enabled: true
    operator: 'GreaterThan'
    threshold: 100
    contactEmails: [
      'maik@familie-vandergaag.nl'
    ]
    thresholdType: 'Forecasted'
  }
}
param filter = {
  and: [
    {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: [
          'rg-'
        ]
      }
    }
    {

     tags: {
        name: 'environment'
        operator: 'In'
        values: [
          'prd'
        ]
      }
    }
  ]
}
