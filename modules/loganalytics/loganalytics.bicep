metadata info = {
  title: 'Log Analytics Workspace'
  description: 'Module for a Log Analytics Workspace'
  version: '0.0.1'
  author: 'Maik van der Gaag'
}

@description('Location of the workspace')
param location string = resourceGroup().location

@description('Name of the workspace')
param name string

@allowed([
  'tst'
  'prd'
  'dev'
  'acc'
])
@description('The environment were the service is beign deployed to (tst, acc, prd, dev)')
param environment string

@description('Sku of the workspace')
@allowed([
  'PerGB2018'
  'Free'
  'Standalone'
  'PerNode'
  'Standard'
  'Premium'
])
param sku string = 'PerGB2018'

@description('The workspace data retention in days. Allowed values are per pricing plan. See pricing tiers documentation for details.')
@minValue(7)
@maxValue(730)
param retentionInDays int = 30

@description('Solutions to add to workspace')
param solutions array = []

@description('Enable lock to prevent accidental deletion')
param enableDeleteLock bool = true

var lockName = '${logAnalyticsWorkspace.name}-lock'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'azla-${name}-${environment}'
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
  }
}

resource logAnalyticsSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in solutions: {
  name: '${solution.name}(${logAnalyticsWorkspace.name})'
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution.name}(${logAnalyticsWorkspace.name})'
    product: solution.product
    publisher: solution.publisher
    promotionCode: solution.promotionCode
  }
}]

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (enableDeleteLock) {
  scope: logAnalyticsWorkspace
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

output workspaceId string = logAnalyticsWorkspace.id
output workspaceName string = logAnalyticsWorkspace.name
