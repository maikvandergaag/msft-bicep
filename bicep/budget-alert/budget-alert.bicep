targetScope = 'subscription'

@description('Name of the budget.')
param name string

@description('The total amount of cost or usage to track with the budget')
param amount int = 1000

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param timeGrain string = 'Monthly'

@description('The start date must be first of the month in YYYY-MM-DD format.')
param startDate string = utcNow('yyyy-MM-ddTHH:00Z')

@description('The last day the schedule should run. Default = 10 year from start date.')
param endDate string = dateTimeAdd(startDate, 'P10Y')

@description('The notifications associated with a budget.')
param notifications object

@description('The first threshold amount that triggers the budget notification.')
param filter object

resource budget 'Microsoft.Consumption/budgets@2024-08-01' = {
  name: name
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: timeGrain
    amount: amount
    category: 'Cost'
    notifications: notifications
    filter:filter
  }
}
